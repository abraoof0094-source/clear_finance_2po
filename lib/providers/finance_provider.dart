import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Only for legacy migration
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/forecast_item.dart';
import '../models/recurring_pattern.dart';
import '../services/database_service.dart';
import '../data/default_categories.dart';

class SystemNotification {
  final String id;
  final DateTime timestamp;
  final String title;
  final String message;
  final bool isRead;

  SystemNotification({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.message,
    this.isRead = false,
  });

  SystemNotification copyWith({bool? isRead}) => SystemNotification(
    id: id,
    timestamp: timestamp,
    title: title,
    message: message,
    isRead: isRead ?? this.isRead,
  );
}

class FinanceProvider extends ChangeNotifier {
  // ─── STATE ───
  List<CategoryModel> _categories = [];
  List<TransactionModel> _transactions = [];
  List<ForecastItem> _forecastItems = [];

  bool _isLoading = true;

  // Home banner message for recurring match
  String? _lastRecurringMatchMessage;

  // 🔔 NEW: In‑app system notifications (not persisted yet)
  final List<SystemNotification> _notifications = [];

  // ─── GETTERS ───
  List<CategoryModel> get categories => _categories;
  List<TransactionModel> get transactions => _transactions;
  List<ForecastItem> get forecastItems => _forecastItems;
  bool get isLoading => _isLoading;

  String? get lastRecurringMatchMessage => _lastRecurringMatchMessage;

  List<SystemNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  // Helper to get pinned categories directly from the list
  List<CategoryModel> get pinnedCategories =>
      _categories.where((c) => c.isPinned).toList();

  // ─── DATABASE ACCESS ───
  Isar get _isar => DatabaseService().syncDb;

  // Setter for banner message
  void setRecurringMatchMessage(String? message) {
    _lastRecurringMatchMessage = message;
    notifyListeners();
  }

  // 🔔 NEW: Notification helpers
  void addSystemNotification({
    required String title,
    required String message,
  }) {
    final n = SystemNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      title: title,
      message: message,
    );
    _notifications.insert(0, n);
    // Keep only recent 30
    if (_notifications.length > 30) {
      _notifications.removeRange(30, _notifications.length);
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // ─── INITIALIZATION ───
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load Categories
      _categories =
      await _isar.categoryModels.where().sortBySortOrder().findAll();

      // 2. Load Transactions (Sort by date desc)
      _transactions =
      await _isar.transactionModels.where().sortByDateDesc().findAll();

      // 3. Load Forecast Items
      _forecastItems = await _isar.forecastItems.where().findAll();

      // REVISED SEEDING LOGIC
      bool isEmptyIsar = _categories.isEmpty && _transactions.isEmpty;

      if (isEmptyIsar) {
        // Try to migrate legacy data first
        await _migrateFromSharedPreferences();

        // Reload to check if migration actually added anything
        _categories =
        await _isar.categoryModels.where().sortBySortOrder().findAll();
        _transactions =
        await _isar.transactionModels.where().sortByDateDesc().findAll();
        _forecastItems = await _isar.forecastItems.where().findAll();
      }

      // If STILL empty (no Isar data, no legacy data found), seed defaults
      if (_categories.isEmpty) {
        await _addDefaultCategories();
      }

      // CHECK RECURRING TRANSACTIONS
      await processRecurringTransactions();
    } catch (e) {
      debugPrint("Error loading Isar data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── RECURRING LOGIC ───

  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    // Find all active patterns where nextDueDate is in the past
    final patterns = await _isar.recurringPatterns
        .filter()
        .isActiveEqualTo(true)
        .and()
        .nextDueDateLessThan(now)
        .findAll();

    if (patterns.isEmpty) return;

    int createdCount = 0;

    await _isar.writeTxn(() async {
      for (var pattern in patterns) {
        // 1. Create the Transaction
        if (pattern.autoLog) {
          final newTx = TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch + createdCount,
            amount: pattern.amount,
            type: pattern.categoryBucket == CategoryBucket.income
                ? TransactionType.income
                : TransactionType.expense,
            date: pattern.nextDueDate,
            categoryName: pattern.name,
            categoryIcon: pattern.emoji,
            categoryBucket: pattern.categoryBucket,
            categoryId: pattern.categoryId,
            note: 'Auto-recurring: ${pattern.name}',
            recurringRuleId: pattern.id, // LINK GENERATED TX TO RULE
          );

          await _isar.transactionModels.put(newTx);
          _transactions.insert(0, newTx);
          createdCount++;

          // 🔔 log notification per auto-logged transaction
          addSystemNotification(
            title: 'Auto‑logged subscription',
            message:
            '${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo) was logged for today.',
          );
        }

        // 2. Advance the Next Due Date
        pattern.nextDueDate =
            calculateNextDate(pattern.nextDueDate, pattern.frequency);
        await _isar.recurringPatterns.put(pattern);
      }
    });

    if (createdCount > 0) {
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      debugPrint("🤖 Auto-logged $createdCount recurring transactions.");
    }

    notifyListeners();
  }

  /// Helper to calculate the next occurrence date
  DateTime calculateNextDate(DateTime current, RecurrenceFrequency freq) {
    switch (freq) {
      case RecurrenceFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
      // Smart monthly add (handles Jan 31 -> Feb 28)
        var newDate = DateTime(current.year, current.month + 1, current.day);
        if (newDate.month != (current.month + 1) % 12 &&
            newDate.day != current.day) {
          // If we jumped a month (e.g. Jan 31 -> Mar 3), backtrack to end of Feb
          return DateTime(current.year, current.month + 2, 0);
        }
        return newDate;
      case RecurrenceFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day);
    }
  }

  /// Adds a new recurring rule to the database
  Future<void> addRecurringPattern(RecurringPattern pattern) async {
    await _isar.writeTxn(() async {
      await _isar.recurringPatterns.put(pattern);
    });

    // 🔔 notification for created rule
    addSystemNotification(
      title: 'Subscription created',
      message:
      '${pattern.name} (₹${pattern.amount.toStringAsFixed(0)}/mo) was added.',
    );

    // Check immediately if it triggers for today
    await processRecurringTransactions();
    notifyListeners();
  }

  // Deletes a recurring rule
  Future<void> deleteRecurringPattern(int id) async {
    await _isar.writeTxn(() async {
      await _isar.recurringPatterns.delete(id);
    });
    notifyListeners();
  }

  // ─── PINNED LOGIC ───
  Future<void> togglePin(int categoryId) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      final cat = _categories[index];
      final updatedCat = cat.copyWith(isPinned: !cat.isPinned);
      await updateCategory(updatedCat);
    }
  }

  bool isPinned(int categoryId) {
    return _categories.any((c) => c.id == categoryId && c.isPinned);
  }

  // ─── TRANSACTIONS ───

  Future<void> addTransaction(TransactionModel tx) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(tx);
    });
    _transactions.insert(0, tx); // Maintain desc order

    // Smart Forecast Logic
    if (_isForecastRelated(tx)) {
      await _applyTransactionEffect(tx);
    }

    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final oldTxIndex = _transactions.indexWhere((t) => t.id == tx.id);
    TransactionModel? oldTx;
    if (oldTxIndex != -1) oldTx = _transactions[oldTxIndex];

    // Revert old effect
    if (oldTx != null && _isForecastRelated(oldTx)) {
      await _revertTransactionEffect(oldTx);
    }

    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(tx);
    });

    if (oldTxIndex != -1) {
      _transactions[oldTxIndex] = tx;
    }

    // Apply new effect
    if (_isForecastRelated(tx)) {
      await _applyTransactionEffect(tx);
    }

    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = _transactions[index];

      if (_isForecastRelated(tx)) {
        await _revertTransactionEffect(tx);
      }

      await _isar.writeTxn(() async {
        await _isar.transactionModels.filter().idEqualTo(id).deleteAll();
      });
      _transactions.removeAt(index);
      notifyListeners();
    }
  }

  // ─── CATEGORIES ───

  Future<void> addCategory(CategoryModel cat) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(cat);
    });
    _categories.add(cat);
    _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(cat);
    });
    final index = _categories.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      _categories[index] = cat;
      // Sync names if needed
      await _syncForecastItemNames(cat);
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.filter().idEqualTo(id).deleteAll();
    });
    _categories.removeWhere((c) => c.id == id);
    _forecastItems.removeWhere((f) => f.categoryId == id);
    notifyListeners();
  }

  Future<void> updateCategoryOrder(List<CategoryModel> newOrder) async {
    _categories = newOrder;
    notifyListeners();

    await _isar.writeTxn(() async {
      for (int i = 0; i < newOrder.length; i++) {
        final cat = newOrder[i].copyWith(sortOrder: i);
        await _isar.categoryModels.put(cat);
      }
    });
  }

  Future<void> _syncForecastItemNames(CategoryModel cat) async {
    final itemsToUpdate =
    _forecastItems.where((f) => f.categoryId == cat.id).toList();
    if (itemsToUpdate.isEmpty) return;

    await _isar.writeTxn(() async {
      for (var item in itemsToUpdate) {
        final updated = item.copyWith(name: cat.name, icon: cat.icon);
        await _isar.forecastItems.put(updated);
        final idx = _forecastItems.indexOf(item);
        if (idx != -1) _forecastItems[idx] = updated;
      }
    });
  }

  // ─── FORECAST ───

  Future<void> addForecastItem(ForecastItem item) async {
    // Check if category exists or needs creation
    ForecastItem itemToSave = item;
    if (item.categoryId == null) {
      itemToSave = await _ensureCategoryForForecastItem(item);
    }

    await _isar.writeTxn(() async {
      await _isar.forecastItems.put(itemToSave);
    });
    _forecastItems.add(itemToSave);
    notifyListeners();
  }

  Future<void> updateForecastItem(ForecastItem item) async {
    await _isar.writeTxn(() async {
      await _isar.forecastItems.put(item);
    });
    final index = _forecastItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _forecastItems[index] = item;

      // Reverse Sync: Update Category if name changed
      if (item.categoryId != null) {
        final catIndex =
        _categories.indexWhere((c) => c.id == item.categoryId);
        if (catIndex != -1) {
          final cat = _categories[catIndex];
          if (cat.name != item.name || cat.icon != item.icon) {
            final updatedCat =
            cat.copyWith(name: item.name, icon: item.icon);
            await updateCategory(updatedCat);
          }
        }
      }
      notifyListeners();
    }
  }

  Future<void> deleteForecastItem(String id) async {
    await _isar.writeTxn(() async {
      await _isar.forecastItems.filter().idEqualTo(id).deleteAll();
    });
    _forecastItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // ─── LOGIC HELPERS ───

  bool _isForecastRelated(TransactionModel tx) {
    return tx.categoryBucket == CategoryBucket.goal ||
        tx.categoryBucket == CategoryBucket.invest ||
        tx.categoryBucket == CategoryBucket.liability;
  }

  Future<void> _applyTransactionEffect(TransactionModel tx) async {
    await _modifyForecastBalance(tx, isRevert: false);
  }

  Future<void> _revertTransactionEffect(TransactionModel tx) async {
    await _modifyForecastBalance(tx, isRevert: true);
  }

  Future<void> _modifyForecastBalance(TransactionModel tx,
      {required bool isRevert}) async {
    // 1. Find the item
    ForecastItem? item;
    if (tx.categoryId != null) {
      try {
        item =
            _forecastItems.firstWhere((f) => f.categoryId == tx.categoryId);
      } catch (_) {}
    }

    // Auto-create if missing (and not reverting)
    if (item == null && !isRevert) {
      // Find category first
      final cat = _categories.firstWhere(
              (c) => c.id == tx.categoryId,
          orElse: () => CategoryModel(
              id: 0,
              name: tx.categoryName,
              icon: tx.categoryIcon,
              bucket: tx.categoryBucket,
              isDefault: false));

      if (cat.id == 0) return;

      final forecastType = tx.categoryBucket == CategoryBucket.goal
          ? ForecastType.goalTarget
          : ForecastType.debtSimple;
      final newItem = ForecastItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: cat.name,
        icon: cat.icon,
        type: forecastType,
        currentOutstanding: tx.amount,
        targetAmount: tx.amount,
        interestRate: 0,
        monthlyEmiOrContribution: 0,
        billingDay: 1,
        colorValue: _pickNextForecastColor().value,
        categoryId: cat.id,
      );
      await addForecastItem(newItem);
      return;
    }

    if (item == null) return;

    // 2. Calculate Principal Portion
    double effectivePrincipalChange = tx.amount;

    if (item.isLiability &&
        item.type != ForecastType.debtSimple &&
        !isRevert) {
      final double monthlyRate = (item.interestRate / 100) / 12;
      final double approxInterest = item.currentOutstanding * monthlyRate;
      final double minRange = approxInterest * 0.8;
      final double maxRange = approxInterest * 1.2;

      final priorPayments =
      _getPriorPaymentsThisMonth(item.categoryId!, tx);
      final bool isInterestAlreadySatisfied =
          priorPayments >= minRange;

      if (!isInterestAlreadySatisfied) {
        if (tx.amount >= minRange && tx.amount <= maxRange) {
          effectivePrincipalChange = 0; // It's just interest
        } else if (tx.amount > maxRange) {
          effectivePrincipalChange = tx.amount - approxInterest;
        } else {
          effectivePrincipalChange = 0;
        }
      }
    }

    // 3. Update Balance
    ForecastItem updatedItem = item;
    if (item.isLiability) {
      if (isRevert) {
        updatedItem = item.copyWith(
            currentOutstanding:
            item.currentOutstanding + effectivePrincipalChange);
      } else {
        final newBal =
            item.currentOutstanding - effectivePrincipalChange;
        updatedItem = item.copyWith(
            currentOutstanding: newBal < 0 ? 0 : newBal);
      }
    } else {
      if (isRevert) {
        final newBal = item.currentOutstanding - tx.amount;
        updatedItem = item.copyWith(
            currentOutstanding: newBal < 0 ? 0 : newBal);
      } else {
        updatedItem = item.copyWith(
            currentOutstanding: item.currentOutstanding + tx.amount);
      }
    }

    await updateForecastItem(updatedItem);
  }

  double _getPriorPaymentsThisMonth(
      int categoryId, TransactionModel currentTx) {
    final now = currentTx.date;
    return _transactions
        .where((t) =>
    t.categoryId == categoryId &&
        t.id != currentTx.id &&
        t.date.year == now.year &&
        t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<ForecastItem> _ensureCategoryForForecastItem(
      ForecastItem item) async {
    final bucket =
    item.isLiability ? CategoryBucket.liability : CategoryBucket.goal;

    // Check if a category with this name already exists
    final existingCatIndex = _categories.indexWhere(
            (c) => c.name == item.name && c.bucket == bucket);

    if (existingCatIndex != -1) {
      return item.copyWith(categoryId: _categories[existingCatIndex].id);
    }

    // Create new
    final newId = (_categories.isEmpty
        ? 1000
        : _categories.map((c) => c.id).reduce(max)) +
        1;
    final newCat = CategoryModel(
        id: newId,
        name: item.name,
        icon: item.icon,
        bucket: bucket,
        isDefault: false);

    await addCategory(newCat);
    return item.copyWith(categoryId: newId);
  }

  Color _pickNextForecastColor() {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6)
    ];
    if (_forecastItems.isEmpty) return colors.first;
    return colors[_forecastItems.length % colors.length];
  }

  // ─── DASHBOARD HELPERS ───
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
  double get totalBalance => totalIncome - totalExpenses;

  // ─── SAFE TO SPEND ───
  double get safeToSpend {
    final now = DateTime.now();
    // 1. Calculate Income (Salary, Bonus)
    final income = _transactions
        .where((t) =>
    t.date.month == now.month &&
        t.date.year == now.year &&
        t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    // 2. Calculate "Already Spent" (Any expense transaction made this month)
    final spent = _transactions
        .where((t) =>
    t.date.month == now.month &&
        t.date.year == now.year &&
        t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // 3. Subtract Mandates (Fixed bills that MUST be paid, e.g. Rent, Utilities)
    double pendingMandates = 0.0;
    for (var cat in _categories
        .where((c) => c.isMandate && (c.monthlyMandate ?? 0) > 0)) {
      final spentOnThisCat = _transactions
          .where((t) =>
      t.categoryId == cat.id &&
          t.date.month == now.month &&
          t.date.year == now.year)
          .fold(0.0, (sum, t) => sum + t.amount);

      if (spentOnThisCat < cat.monthlyMandate!) {
        pendingMandates += (cat.monthlyMandate! - spentOnThisCat);
      }
    }

    return income - spent - pendingMandates;
  }

  // ─── DATA MIGRATION ───
  Future<void> _addDefaultCategories() async {
    final defaults = DefaultCategories.defaults;
    await _isar.writeTxn(() async {
      await _isar.categoryModels.putAll(defaults);
    });
    _categories = defaults;
  }

  Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Categories
    final catString = prefs.getString('categories');
    List<CategoryModel> legacyCats = [];
    if (catString != null) {
      final List decoded = json.decode(catString);
      legacyCats =
          decoded.map((e) => CategoryModel.fromJson(e)).toList();
    }

    // 1b. Pinned IDs (Merge into CategoryModel)
    final pinnedList = prefs.getStringList('pinned_categories');
    if (pinnedList != null && legacyCats.isNotEmpty) {
      final pinnedIds =
      pinnedList.map((e) => int.parse(e)).toSet();
      legacyCats = legacyCats.map((c) {
        if (pinnedIds.contains(c.id)) {
          return c.copyWith(isPinned: true);
        }
        return c;
      }).toList();
    }

    // 2. Transactions
    final txString = prefs.getString('transactions');
    List<TransactionModel> legacyTx = [];
    if (txString != null) {
      final List decoded = json.decode(txString);
      legacyTx =
          decoded.map((e) => TransactionModel.fromJson(e)).toList();
    }

    // 3. Forecast
    final fcString = prefs.getString('forecast_items');
    List<ForecastItem> legacyFc = [];
    if (fcString != null) {
      final List decoded = json.decode(fcString);
      legacyFc =
          decoded.map((e) => ForecastItem.fromJson(e)).toList();
    }

    if (legacyCats.isEmpty && legacyTx.isEmpty) return;

    debugPrint("🔄 Migrating ${legacyTx.length} TXs to Isar...");

    await _isar.writeTxn(() async {
      await _isar.categoryModels.putAll(legacyCats);
      await _isar.transactionModels.putAll(legacyTx);
      await _isar.forecastItems.putAll(legacyFc);
    });
  }
}
