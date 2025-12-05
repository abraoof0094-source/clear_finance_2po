import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/forecast_item.dart';
import '../models/transaction_record.dart';
import '../models/transaction.dart'; // Exports TransactionType
import '../models/category.dart';
import '../models/salary_profile.dart';

class FinanceProvider extends ChangeNotifier {
  SalaryProfile? salaryProfile;
  List<Transaction> transactions = [];
  List<CategoryModel> categories = [];

  List<ForecastItem> forecastItems = [];
  List<TransactionRecord> forecastTransactions = [];

  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final salaryString = prefs.getString('salary_profile');
    if (salaryString != null) {
      try {
        salaryProfile = SalaryProfile.fromJson(jsonDecode(salaryString));
      } catch (e) { debugPrint("Error loading salary: $e"); }
    }

    final txList = prefs.getStringList('transactions');
    if (txList != null) {
      transactions = txList.map((t) => Transaction.fromJson(jsonDecode(t))).toList();
    }

    final catList = prefs.getStringList('categories');
    if (catList != null) {
      categories = catList.map((c) => CategoryModel.fromJson(jsonDecode(c))).toList();
    }

    final forecastList = prefs.getStringList('forecast_items');
    if (forecastList != null) {
      forecastItems = forecastList.map((f) => ForecastItem.fromJson(jsonDecode(f))).toList();
    }

    final forecastTxList = prefs.getStringList('forecast_transactions');
    if (forecastTxList != null) {
      forecastTransactions = forecastTxList.map((t) => TransactionRecord.fromJson(jsonDecode(t))).toList();
      forecastTransactions.sort((a, b) => b.date.compareTo(a.date));
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (salaryProfile != null) prefs.setString('salary_profile', jsonEncode(salaryProfile!.toJson()));
    prefs.setStringList('transactions', transactions.map((t) => jsonEncode(t.toJson())).toList());
    prefs.setStringList('categories', categories.map((c) => jsonEncode(c.toJson())).toList());
    prefs.setStringList('forecast_items', forecastItems.map((f) => jsonEncode(f.toJson())).toList());
    prefs.setStringList('forecast_transactions', forecastTransactions.map((t) => jsonEncode(t.toJson())).toList());
  }

  // --- APP METHODS ---
  Future<void> updateSalaryProfile(SalaryProfile profile) async {
    salaryProfile = profile;
    notifyListeners();
    _saveData();
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
    notifyListeners();
    _saveData();
  }

  // FIXED: Comparing Enum types (TransactionType.income)
  double get totalBalance {
    double income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    double expense = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  double get totalIncome => transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
  double get totalExpenses => transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

  Future<void> addCategory(CategoryModel category) async {
    categories.add(category);
    notifyListeners();
    _saveData();
  }

  void updateCategory(CategoryModel category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      notifyListeners();
      _saveData();
    }
  }

  void deleteCategory(int id) {
    categories.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveData();
  }

  // --- FORECAST METHODS ---
  void addForecastItem(ForecastItem item) {
    forecastItems.add(item);
    notifyListeners();
    _saveData();
  }

  void deleteForecastItem(String id) {
    forecastItems.removeWhere((item) => item.id == id);
    notifyListeners();
    _saveData();
  }

  void updateForecastItem(ForecastItem item) {
    final index = forecastItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      forecastItems[index] = item;
      notifyListeners();
      _saveData();
    }
  }

  // Using isLiability getter from ForecastItem
  double getTotalAssets() {
    return forecastItems
        .where((item) => !item.isLiability)
        .fold(0.0, (sum, item) => sum + item.currentAmount);
  }

  double getTotalLiabilities() {
    return forecastItems
        .where((item) => item.isLiability)
        .fold(0.0, (sum, item) => sum + item.currentAmount);
  }

  double get netWorth => getTotalAssets() - getTotalLiabilities();
  double getNetWorth() => netWorth;

  // --- FORECAST TRANSACTION HISTORY ---
  void addForecastTransaction(TransactionRecord record) {
    forecastTransactions.add(record);
    forecastTransactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    _saveData();
  }

  void deleteForecastTransaction(String id) {
    forecastTransactions.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveData();
  }

  List<TransactionRecord> getRecentForecastTransactions(String itemId, {int limit = 10}) {
    return forecastTransactions.where((t) => t.itemId == itemId).take(limit).toList();
  }
}
