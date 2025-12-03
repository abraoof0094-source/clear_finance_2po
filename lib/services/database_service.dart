import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as models;
import '../models/budget.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clear_finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        type $integerType,
        mainCategory $textType,
        subCategory $textType,
        amount $realType,
        date $textType,
        time $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        category $textType,
        amount $realType,
        period $textType,
        startDate $textType,
        endDate TEXT
      )
    ''');
  }

  Future<models.Transaction> createTransaction(models.Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
    return transaction;
  }

  Future<List<models.Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await instance.database;
    
    final monthStr = month.toString().padLeft(2, '0');
    final yearMonthPrefix = '$year-$monthStr';

    final result = await db.query(
      'transactions',
      where: 'date LIKE ?',
      whereArgs: ['$yearMonthPrefix%'],
      orderBy: 'date DESC, time DESC',
    );

    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  Future<List<models.Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, time DESC',
    );
    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  Future<int> updateTransaction(models.Transaction transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Budget> createBudget(Budget budget) async {
    final db = await instance.database;
    await db.insert('budgets', budget.toMap());
    return budget;
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets');
    return result.map((json) => Budget.fromMap(json)).toList();
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await instance.database;
    return db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(String id) async {
    final db = await instance.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
