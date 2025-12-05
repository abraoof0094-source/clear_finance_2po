import 'package:flutter/material.dart';
import 'category.dart'; // for CategoryBucket

// Enum stays as you defined
enum TransactionType { income, expense, investment }

class Transaction {
  final int id;                       // was String
  final double amount;
  final TransactionType type;
  final String categoryName;
  final String categoryIcon;
  final DateTime date;
  final String? note;
  final CategoryBucket? categoryBucket; // NEW: link to your 4 buckets

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.categoryIcon = '📝',
    required this.date,
    this.note,
    this.categoryBucket,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString(),               // enum as String
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'date': date.toIso8601String(),
      'note': note,
      'categoryBucket': categoryBucket == null
          ? null
          : categoryBucketToString(categoryBucket!), // from category.dart
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    TransactionType parseType(String? str) {
      return TransactionType.values.firstWhere(
            (e) => e.toString() == str,
        orElse: () => TransactionType.expense,
      );
    }

    return Transaction(
      id: (json['id'] as int?) ?? 0, // handles old data if any
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: parseType(json['type'] as String?),
      categoryName: json['categoryName'] as String? ?? 'Unknown',
      categoryIcon: json['categoryIcon'] as String? ?? '📝',
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      categoryBucket: json['categoryBucket'] == null
          ? null
          : categoryBucketFromString(json['categoryBucket'] as String?),
    );
  }
}
