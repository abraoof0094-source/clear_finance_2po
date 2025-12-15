import 'package:isar/isar.dart';
import 'category_model.dart'; // Import for CategoryBucket if needed

part 'recurring_pattern.g.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

@collection
class RecurringPattern {
  Id id = Isar.autoIncrement;

  late String name; // e.g., "Netflix", "House Rent"
  late double amount;
  late String emoji; // Visual cue

  // Link to the category (Foreign Key logic)
  late int categoryId;
  @Enumerated(EnumType.ordinal)
  late CategoryBucket categoryBucket;

  // 🗓️ TIMING LOGIC
  late DateTime startDate;
  late DateTime nextDueDate;

  @Enumerated(EnumType.ordinal)
  late RecurrenceFrequency frequency;

  // ⚙️ SETTINGS
  bool isActive = true; // User can pause subscription without deleting
  bool autoLog = true;  // If true, creates TX automatically. If false, just reminds user.
}
