import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class FinanceProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;

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

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _updateBalance();
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _updateBalance();
    notifyListeners();
  }

  void _updateBalance() {
    _balance = totalIncome - totalExpense;
  }

  // Load dummy data for testing
  void loadDummyData() {
    _transactions = [
      Transaction(
        id: '1',
        title: 'Salary',
        amount: 50000,
        type: TransactionType.income,
        category: 'Salary',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: '2',
        title: 'Grocery Shopping',
        amount: 2500,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: '3',
        title: 'Electricity Bill',
        amount: 1200,
        type: TransactionType.expense,
        category: 'Bills',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    _updateBalance();
    notifyListeners();
  }
}
