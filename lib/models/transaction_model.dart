import 'dart:convert';
import 'package:isar/isar.dart';
import 'category_model.dart'; // Ensure CategoryBucket and helpers are here

part 'transaction_model.g.dart';

enum TransactionType {
  income,
  expense,
  investment,
}

/// Convert TransactionType enum → string for persistence/JSON.
String transactionTypeToString(TransactionType type) {
  return type.name;
}

/// Convert string → TransactionType enum.
TransactionType transactionTypeFromString(String? value) {
  if (value == null) return TransactionType.expense;
  try {
    return TransactionType.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return TransactionType.expense;
  }
}

@collection
class TransactionModel {
  /// Isar auto-incrementing ID.
  Id isarId = Isar.autoIncrement;

  /// Your original logic ID (timestamp based).
  @Index(unique: true)
  final int id;

  final double amount;

  @Enumerated(EnumType.name) // Store as "income", "expense" etc.
  final TransactionType type;

  @Index() // Index for fast filtering by category
  final int? categoryId;

  final String categoryName;
  final String categoryIcon;

  @Index() // Index for fast sorting/filtering by date
  final DateTime date;

  final String? note;

  @Enumerated(EnumType.name)
  final CategoryBucket categoryBucket;

  // 🟢 NEW: Link to parent Recurring Pattern (Nullable)
  @Index()
  final int? recurringRuleId;

  TransactionModel({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.categoryName,
    this.categoryIcon = '📝',
    required this.date,
    this.note,
    required this.categoryBucket,
    this.recurringRuleId,
  });

  TransactionModel copyWith({
    Id? isarId,
    int? id,
    double? amount,
    TransactionType? type,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? date,
    String? note,
    CategoryBucket? categoryBucket,
    int? recurringRuleId,
  }) {
    return TransactionModel(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      note: note ?? this.note,
      categoryBucket: categoryBucket ?? this.categoryBucket,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
    );
  }

  // ─── LEGACY JSON SUPPORT ───

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': transactionTypeToString(type),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'date': date.toIso8601String(),
      'note': note,
      'categoryBucket': categoryBucketToString(categoryBucket),
      'recurringRuleId': recurringRuleId, // Include in JSON
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as int?) ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: transactionTypeFromString(json['type'] as String?),
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String? ?? 'Unknown',
      categoryIcon: json['categoryIcon'] as String? ?? '📝',
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      categoryBucket: categoryBucketFromString(json['categoryBucket'] as String?),
      recurringRuleId: json['recurringRuleId'] as int?, // Read from JSON
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TransactionModel.fromJsonString(String source) =>
      TransactionModel.fromJson(json.decode(source) as Map<String, dynamic>);
}
