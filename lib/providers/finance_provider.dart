import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/forecast_item.dart';
import '../data/default_categories.dart';

class FinanceProvider extends ChangeNotifier {
  // Core state
  List<TransactionModel> transactions = [];
  List<CategoryModel> categories = [];
  List<ForecastItem> forecastItems = [];

  // ───────── Persistence ─────────
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final txList = prefs.getStringList('transactions');
    if (txList != null) {
      transactions = txList.map((t) => TransactionModel.fromJson(jsonDecode(t))).toList();
    } else {
      transactions = [];
    }
    final catList = prefs.getStringList('categories');
    if (catList != null && catList.isNotEmpty) {
      categories = catList.map((c) => CategoryModel.fromJson(jsonDecode(c))).toList();
    } else {
      categories = List<CategoryModel>.from(defaultCategories);
      await _saveCategoriesOnly();
    }
    final forecastList = prefs.getStringList('forecast_items');
    if (forecastList != null) {
      forecastItems = forecastList.map((f) => ForecastItem.fromJson(jsonDecode(f))).toList();
    } else {
      forecastItems = [];
    }
    notifyListeners();
  }

  Future<void> loadTransactions() => loadData();

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('transactions', transactions.map((t) => jsonEncode(t.toJson())).toList());
    await prefs.setStringList('categories', categories.map((c) => jsonEncode(c.toJson())).toList());
    await prefs.setStringList('forecast_items', forecastItems.map((f) => jsonEncode(f.toJson())).toList());
  }

  Future<void> _saveCategoriesOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', categories.map((c) => jsonEncode(c.toJson())).toList());
  }

  // ───────── CASHFLOW: Transactions ─────────
  void addTransaction(TransactionModel tx) {
    transactions.add(tx);
    if (_isForecastRelated(tx)) {
      _applyTransactionEffect(tx);
    }
    notifyListeners();
    _saveData();
  }

  void updateTransaction(TransactionModel updatedTx) {
    final index = transactions.indexWhere((t) => t.id == updatedTx.id);
    if (index != -1) {
      final oldTx = transactions[index];
      if (_isForecastRelated(oldTx)) {
        _revertTransactionEffect(oldTx);
      }
      transactions[index] = updatedTx;
      if (_isForecastRelated(updatedTx)) {
        _applyTransactionEffect(updatedTx);
      }
      notifyListeners();
      _saveData();
    }
  }

  void deleteTransaction(int id) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = transactions[index];
      if (_isForecastRelated(tx)) {
        _revertTransactionEffect(tx);
      }
      transactions.removeAt(index);
      notifyListeners();
      _saveData();
    }
  }

  bool _isForecastRelated(TransactionModel tx) {
    return tx.categoryBucket == CategoryBucket.goal ||
        tx.categoryBucket == CategoryBucket.invest ||
        tx.categoryBucket == CategoryBucket.liability;
  }

  double get totalIncome => transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpenses => transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
  double get totalBalance => totalIncome - totalExpenses;

  List<TransactionModel> transactionsForMonth(int year, int month) {
    return transactions.where((t) => t.date.year == year && t.date.month == month).toList();
  }

  // ───────── CATEGORIES ─────────
  Future<void> addCategory(CategoryModel category) async {
    categories.add(category);
    notifyListeners();
    _saveData();
  }

  void updateCategory(CategoryModel category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      for (int i = 0; i < forecastItems.length; i++) {
        final item = forecastItems[i];
        if (item.categoryId == category.id) {
          forecastItems[i] = item.copyWith(name: category.name, icon: category.icon);
        }
      }
      notifyListeners();
      _saveData();
    }
  }

  void deleteCategory(int id) {
    categories.removeWhere((c) => c.id == id);
    forecastItems.removeWhere((item) => item.categoryId == id);
    notifyListeners();
    _saveData();
  }

  // ───────── FORECAST ITEMS ─────────
  void addForecastItem(ForecastItem item) {
    final withCategory = item.categoryId == null ? _ensureCategoryForForecastItem(item) : item;
    forecastItems.add(withCategory);
    notifyListeners();
    _saveData();
  }

  void updateForecastItem(ForecastItem item) {
    final index = forecastItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      forecastItems[index] = item;
      if (item.categoryId != null) {
        final cIndex = categories.indexWhere((c) => c.id == item.categoryId);
        if (cIndex != -1) {
          final cat = categories[cIndex];
          categories[cIndex] = cat.copyWith(name: item.name, icon: item.icon);
        }
      }
      notifyListeners();
      _saveData();
    }
  }

  void deleteForecastItem(String id) {
    forecastItems.removeWhere((item) => item.id == id);
    notifyListeners();
    _saveData();
  }

  double getTotalAssets() => forecastItems.where((item) => !item.isLiability).fold(0.0, (sum, item) => sum + item.currentOutstanding);
  double getTotalLiabilities() => forecastItems.where((item) => item.isLiability).fold(0.0, (sum, item) => sum + item.currentOutstanding);
  double get netWorth => getTotalAssets() - getTotalLiabilities();

  double get totalOriginalDebt => forecastItems.where((item) => item.isLiability && item.targetAmount > 0).fold(0.0, (sum, item) => sum + item.targetAmount);
  double get totalCurrentDebt => forecastItems.where((item) => item.isLiability).fold(0.0, (sum, item) => sum + item.currentOutstanding);

  double get totalDebtProgress {
    if (totalOriginalDebt <= 0) return 0.0;
    final paid = (totalOriginalDebt - totalCurrentDebt).clamp(0.0, totalOriginalDebt);
    return paid / totalOriginalDebt;
  }

  DateTime get _monthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime get _nextMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
  }

  double get extraDebtPaidThisMonth {
    final start = _monthStart;
    final end = _nextMonthStart;
    return transactions
        .where((t) => (t.categoryBucket == CategoryBucket.liability || t.categoryBucket == CategoryBucket.goal) && !t.date.isBefore(start) && t.date.isBefore(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ───────── SYNC LOGIC (ROBUST SMART SPLIT) ─────────

  void _applyTransactionEffect(TransactionModel tx) {
    _modifyForecastBalance(tx, isRevert: false);
  }

  void _revertTransactionEffect(TransactionModel tx) {
    _modifyForecastBalance(tx, isRevert: true);
  }

  /// Helper: Check how much was already paid this month for this category.
  /// (Excludes the current transaction `tx` itself).
  double _getPriorPaymentsThisMonth(int categoryId, TransactionModel currentTx) {
    final now = currentTx.date;
    return transactions
        .where((t) =>
    t.categoryId == categoryId &&
        t.id != currentTx.id && // Exclude self
        t.date.year == now.year &&
        t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _modifyForecastBalance(TransactionModel tx, {required bool isRevert}) {
    CategoryModel? cat;
    if (tx.categoryId != null) {
      try {
        cat = categories.firstWhere((c) => c.id == tx.categoryId);
      } catch (_) {}
    }

    if (cat == null) cat = _findCategoryForTransaction(tx);
    if (cat == null) return;

    ForecastItem? item = _findForecastItemByCategoryId(cat.id);

    // Create item if missing
    if (item == null && !isRevert) {
      final forecastType = tx.categoryBucket == CategoryBucket.goal ? ForecastType.goalTarget : ForecastType.debtSimple;
      item = ForecastItem(
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
      forecastItems.add(item);
      return;
    }

    if (item == null) return;

    final index = forecastItems.indexOf(item);

    // ─── ROBUST TIME-BASED SPLIT LOGIC ───
    double effectivePrincipalChange = tx.amount;

    // We only apply this logic for Interest-Bearing Liabilities (not Simple Debt or Goals)
    // AND we skip complex logic on Revert (safely assume revert adds back full amount)
    if (item.isLiability && item.type != ForecastType.debtSimple && !isRevert) {

      // 1. Calculate "Approximate Interest" (AI)
      final double monthlyRate = (item.interestRate / 100) / 12;
      final double approxInterest = item.currentOutstanding * monthlyRate;

      // 2. Define Tolerance Range (-20% to +20%)
      final double minRange = approxInterest * 0.8;
      final double maxRange = approxInterest * 1.2;

      // 3. Check History: Is interest already paid?
      final double priorPayments = _getPriorPaymentsThisMonth(cat.id, tx);
      // If prior payments exceed minRange, we assume interest is largely satisfied.
      final bool isInterestAlreadySatisfied = priorPayments >= minRange;

      if (isInterestAlreadySatisfied) {
        // SCENARIO: Interest was already paid by a previous transaction.
        // RESULT: Entire new amount goes to Principal.
        effectivePrincipalChange = tx.amount;
      } else {
        // SCENARIO: Interest is NOT yet paid. Analyze current transaction.

        if (tx.amount >= minRange && tx.amount <= maxRange) {
          // Case A: Transaction is within range (e.g., Bank charged 1810, AI was 1800).
          // Treat entire amount as REAL INTEREST.
          // Principal Deduction = 0.
          effectivePrincipalChange = 0;
        } else if (tx.amount > maxRange) {
          // Case B: Transaction is significantly higher (e.g., Paying 5000, AI was 1800).
          // Deduct Approximate Interest, rest is Principal.
          effectivePrincipalChange = tx.amount - approxInterest;
        } else {
          // Case C: Below Range (Partial payment).
          // Treat as partial interest payment -> No Principal deduction.
          // (Or you could split proportionally, but safer to assume it's interest first).
          effectivePrincipalChange = 0;
        }
      }
    } else if (isRevert && item.isLiability && item.type != ForecastType.debtSimple) {
      // On Revert, we simplify.
      // Since we don't store "principalPortion" in Transaction, we assume full revert.
      // This is a limitation, but usually acceptable for simple undo.
      effectivePrincipalChange = tx.amount;
    }
    // ─── END LOGIC ───

    if (item.isLiability) {
      if (isRevert) {
        forecastItems[index] = item.copyWith(currentOutstanding: item.currentOutstanding + effectivePrincipalChange);
      } else {
        final newBal = item.currentOutstanding - effectivePrincipalChange;
        forecastItems[index] = item.copyWith(currentOutstanding: newBal < 0 ? 0 : newBal);
      }
    } else {
      // Goal logic remains the same
      if (isRevert) {
        final newBal = item.currentOutstanding - tx.amount;
        forecastItems[index] = item.copyWith(currentOutstanding: newBal < 0 ? 0 : newBal);
      } else {
        forecastItems[index] = item.copyWith(currentOutstanding: item.currentOutstanding + tx.amount);
      }
    }
  }

  CategoryModel? _findCategoryForTransaction(TransactionModel tx) {
    try {
      return categories.firstWhere((c) => c.name == tx.categoryName && c.bucket == tx.categoryBucket);
    } catch (_) {
      return null;
    }
  }

  ForecastItem? _findForecastItemByCategoryId(int categoryId) {
    try {
      return forecastItems.firstWhere((f) => f.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  ForecastItem _ensureCategoryForForecastItem(ForecastItem item) {
    final bucket = item.isLiability ? CategoryBucket.liability : CategoryBucket.goal;
    final existing = categories.where((c) => c.name == item.name && c.bucket == bucket);
    if (existing.isNotEmpty) {
      return item.copyWith(categoryId: existing.first.id);
    }
    final newId = (categories.isEmpty ? 0 : categories.map((c) => c.id).reduce(max)) + 1;
    final newCat = CategoryModel(id: newId, name: item.name, icon: item.icon, bucket: bucket, isDefault: false);
    categories.add(newCat);
    return item.copyWith(categoryId: newId);
  }

  Color _pickNextForecastColor() {
    const colors = [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF8B5CF6)];
    if (forecastItems.isEmpty) return colors.first;
    return colors[forecastItems.length % colors.length];
  }
}