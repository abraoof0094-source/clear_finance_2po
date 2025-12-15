import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/forecast_item.dart';
import '../models/recurring_pattern.dart'; // <--- 1. IMPORT THIS

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Future<Isar> db;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    db = _initDB();
  }

  Future<Isar> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();

    // Open the Isar database with all schemas
    return await Isar.open(
      [
        TransactionModelSchema,
        CategoryModelSchema,
        ForecastItemSchema,
        RecurringPatternSchema, // <--- 2. ADD THIS SCHEMA
      ],
      directory: dir.path,
      inspector: true,
    );
  }

  Isar get syncDb {
    return Isar.getInstance()!;
  }
}
