import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model; // Alias to avoid conflict with sqflite Transaction
import '../models/salary_profile.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clear_finance.db');

    return await openDatabase(
      path,
      version: 3, // Updated version for new schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Transactions Table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        amount REAL,
        categoryName TEXT,
        categoryIcon TEXT,
        date TEXT,
        note TEXT,
        isFixed INTEGER
      )
    ''');

    // 2. Salary Profile Table
    await db.execute('''
      CREATE TABLE salary_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monthlySalary REAL,
        investmentGoalPercentage REAL,
        investmentMode TEXT,
        investmentGoalAmount REAL
      )
    ''');

    // 3. Categories Table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        icon TEXT,
        type TEXT,
        nature TEXT,
        amount REAL,
        is_system_default INTEGER
      )
    ''');

    // 4. Populate Default Categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Simple migration: Drop and recreate for dev
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS salary_profile');
    await _onCreate(db, newVersion);
  }

  // --- DEFAULT CATEGORIES ---
  Future<void> _insertDefaultCategories(Database db) async {
    final defaults = [
      // INCOME - Fixed
      CategoryModel(name: 'Salary', icon: '💰', type: CategoryType.income, nature: CategoryNature.fixed, isSystemDefault: true),
      CategoryModel(name: 'Rental Income', icon: '🏠', type: CategoryType.income, nature: CategoryNature.fixed),

      // INCOME - Variable
      CategoryModel(name: 'Freelance', icon: '💻', type: CategoryType.income, nature: CategoryNature.variable),
      CategoryModel(name: 'Bonus', icon: '🎁', type: CategoryType.income, nature: CategoryNature.variable),
      CategoryModel(name: 'Refunds', icon: '↩️', type: CategoryType.income, nature: CategoryNature.variable),

      // EXPENSE - Fixed (Commitments)
      CategoryModel(name: 'Rent', icon: '🏠', type: CategoryType.expense, nature: CategoryNature.fixed),
      CategoryModel(name: 'EMI', icon: '🏦', type: CategoryType.expense, nature: CategoryNature.fixed),
      CategoryModel(name: 'Internet', icon: '🌐', type: CategoryType.expense, nature: CategoryNature.fixed),
      CategoryModel(name: 'Subscriptions', icon: '📺', type: CategoryType.expense, nature: CategoryNature.fixed),

      // EXPENSE - Variable (Spending Tags)
      CategoryModel(name: 'Groceries', icon: '🛒', type: CategoryType.expense, nature: CategoryNature.variable, isSystemDefault: true),
      CategoryModel(name: 'Food & Dining', icon: '🍔', type: CategoryType.expense, nature: CategoryNature.variable, isSystemDefault: true),
      CategoryModel(name: 'Transport', icon: '🚕', type: CategoryType.expense, nature: CategoryNature.variable),
      CategoryModel(name: 'Shopping', icon: '🛍️', type: CategoryType.expense, nature: CategoryNature.variable),
      CategoryModel(name: 'Health', icon: '💊', type: CategoryType.expense, nature: CategoryNature.variable),
      CategoryModel(name: 'Travel', icon: '✈️', type: CategoryType.expense, nature: CategoryNature.variable),

      // INVESTMENT - Fixed
      CategoryModel(name: 'SIP', icon: '📈', type: CategoryType.investment, nature: CategoryNature.fixed),
      CategoryModel(name: 'PPF', icon: '🛡️', type: CategoryType.investment, nature: CategoryNature.fixed),

      // INVESTMENT - Variable
      CategoryModel(name: 'Stocks', icon: '📊', type: CategoryType.investment, nature: CategoryNature.variable),
      CategoryModel(name: 'Gold', icon: '🥇', type: CategoryType.investment, nature: CategoryNature.variable),
    ];

    final batch = db.batch();
    for (var cat in defaults) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit();
  }

  // --- CATEGORY CRUD ---

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- TRANSACTION CRUD (Using Alias model.Transaction) ---

  Future<void> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: "date DESC",
    );
    return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- SALARY PROFILE ---

  Future<void> insertSalaryProfile(SalaryProfile profile) async {
    final db = await database;
    await db.delete('salary_profile');
    await db.insert('salary_profile', profile.toMap());
  }

  Future<SalaryProfile?> getSalaryProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('salary_profile');
    if (maps.isNotEmpty) {
      return SalaryProfile.fromMap(maps.first);
    }
    return null;
  }
}
