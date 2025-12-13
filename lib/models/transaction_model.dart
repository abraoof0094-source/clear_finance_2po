import 'dart:convert';

import 'category_model.dart'; // CategoryBucket + helpers

/// High-level type of a transaction.
enum TransactionType {
  income,
  expense,
  investment,
}

/// Convert TransactionType enum → string for persistence.
String transactionTypeToString(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'income';
    case TransactionType.expense:
      return 'expense';
    case TransactionType.investment:
      return 'investment';
  }
}

/// Convert string → TransactionType enum (defaults to expense).
TransactionType transactionTypeFromString(String? value) {
  switch (value) {
    case 'income':
      return TransactionType.income;
    case 'expense':
      return TransactionType.expense;
    case 'investment':
      return TransactionType.investment;
    default:
      return TransactionType.expense;
  }
}

/// Represents a single money movement (income, expense, or investment).
class TransactionModel {
  final int id;
  final double amount;
  final TransactionType type;

  /// Optional link to the CategoryModel this transaction belongs to.
  final int? categoryId;

  final String categoryName;
  final String categoryIcon;
  final DateTime date;
  final String? note;
  final CategoryBucket categoryBucket;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.categoryName,
    this.categoryIcon = '📝',
    required this.date,
    this.note,
    required this.categoryBucket,
  });

  TransactionModel copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? date,
    String? note,
    CategoryBucket? categoryBucket,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      note: note ?? this.note,
      categoryBucket: categoryBucket ?? this.categoryBucket,
    );
  }

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
      categoryBucket:
      categoryBucketFromString(json['categoryBucket'] as String?),
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TransactionModel.fromJsonString(String source) =>
      TransactionModel.fromJson(json.decode(source) as Map<String, dynamic>);
}