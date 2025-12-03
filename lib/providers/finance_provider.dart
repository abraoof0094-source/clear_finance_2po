import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import '../data/categories.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  DateTime get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;

  // Calculate totals
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalInvestment {
    return _transactions
        .where((t) => t.type == TransactionType.investment)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense - totalInvestment;

  // Month navigation
  void goToPreviousMonth() {
    _currentMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month - 1,
      1,
    );
    loadTransactionsForCurrentMonth();
    notifyListeners();
  }

  void goToNextMonth() {
    _currentMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      1,
    );
    loadTransactionsForCurrentMonth();
    notifyListeners();
  }

  // Load transactions for current month
  Future<void> loadTransactionsForCurrentMonth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getTransactionsByMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all transactions (for analysis)
  Future<void> loadAllTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _db.getAllTransactions();
    } catch (e) {
      debugPrint('Error loading all transactions: $e');
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Transaction operations
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _db.createTransaction(transaction);
      
      // Add to local list if it belongs to current month
      final transactionDate = DateTime.parse(transaction.date);
      if (transactionDate.year == _currentMonth.year &&
          transactionDate.month == _currentMonth.month) {
        _transactions.insert(0, transaction);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _db.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Budget operations
  Future<void> loadBudgets() async {
    try {
      _budgets = await _db.getAllBudgets();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      _budgets = [];
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _db.createBudget(budget);
      _budgets.add(budget);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding budget: $e');
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _db.updateBudget(budget);
      
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _db.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  // Category analysis
  Map<String, double> getCategoryTotals(TransactionType type) {
    final categoryTotals = <String, double>{};
    
    for (final transaction in _transactions.where((t) => t.type == type)) {
      categoryTotals[transaction.mainCategory] = 
          (categoryTotals[transaction.mainCategory] ?? 0) + transaction.amount;
    }
    
    return categoryTotals;
  }

  // Get transactions for a date range
  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      final date = DateTime.parse(t.date);
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
             date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
