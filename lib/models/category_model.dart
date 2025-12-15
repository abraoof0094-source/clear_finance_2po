import 'package:isar/isar.dart';

// ⚠️ IMPORTANT: Run 'flutter pub run build_runner build' to generate this file.
part 'category_model.g.dart';

enum CategoryBucket {
  income,
  expense,
  invest,
  liability,
  goal,
}

/// Convert CategoryBucket → string for persistence.
String categoryBucketToString(CategoryBucket bucket) {
  switch (bucket) {
    case CategoryBucket.income:
      return 'income';
    case CategoryBucket.expense:
      return 'expense';
    case CategoryBucket.invest:
      return 'invest';
    case CategoryBucket.liability:
      return 'liability';
    case CategoryBucket.goal:
      return 'goal';
  }
}

/// Convert string → CategoryBucket (defaults to expense).
CategoryBucket categoryBucketFromString(String? value) {
  switch (value) {
    case 'income':
      return CategoryBucket.income;
    case 'expense':
      return CategoryBucket.expense;
    case 'invest':
      return CategoryBucket.invest;
    case 'liability':
      return CategoryBucket.liability;
    case 'goal':
      return CategoryBucket.goal;
    default:
      return CategoryBucket.expense;
  }
}

@collection
class CategoryModel {
  /// Isar auto-incrementing ID.
  /// In Isar 3.x, use the 'Id' type alias. It maps to int automatically.
  Id isarId = Isar.autoIncrement;

  /// Your original logic ID. We keep this to avoid breaking existing logic.
  @Index(unique: true)
  final int id;

  final String name;
  final String icon;

  @Enumerated(EnumType.ordinal) // Stores as 0, 1, 2... in DB
  final CategoryBucket bucket;

  final bool isDefault;

  /// Determines the display order in the list. Lower numbers appear first.
  final int sortOrder;

  /// If true, this category is treated as a monthly mandate/essential.
  final bool isMandate;

  /// Planned monthly amount for this mandate (used for Safe to spend etc.).
  final double? monthlyMandate;

  /// If true, this category appears in the "Quick Access" bar on Add Transaction screen.
  final bool isPinned;

  CategoryModel({
    this.isarId = Isar.autoIncrement, // Default value needed
    required this.id,
    required this.name,
    required this.icon,
    required this.bucket,
    required this.isDefault,
    this.isMandate = false,
    this.monthlyMandate,
    this.isPinned = false,
    this.sortOrder = 0,
  });

  CategoryModel copyWith({
    Id? isarId,
    int? id,
    String? name,
    String? icon,
    CategoryBucket? bucket,
    bool? isDefault,
    bool? isMandate,
    double? monthlyMandate,
    bool? isPinned,
    int? sortOrder,
  }) {
    return CategoryModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bucket: bucket ?? this.bucket,
      isDefault: isDefault ?? this.isDefault,
      isMandate: isMandate ?? this.isMandate,
      monthlyMandate: monthlyMandate ?? this.monthlyMandate,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // ─── LEGACY JSON SUPPORT ───

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'bucket': bucket.index,
      'isDefault': isDefault,
      'isMandate': isMandate,
      'monthlyMandate': monthlyMandate,
      'isPinned': isPinned,
      'sortOrder': sortOrder,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      bucket: CategoryBucket.values[json['bucket'] as int],
      isDefault: json['isDefault'] as bool? ?? false,
      isMandate: json['isMandate'] as bool? ?? false,
      monthlyMandate: json['monthlyMandate'] == null
          ? null
          : (json['monthlyMandate'] as num).toDouble(),
      isPinned: json['isPinned'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
