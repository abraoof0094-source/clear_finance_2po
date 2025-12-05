import 'package:flutter/material.dart';

// Define Enum to fix UI errors
enum TransactionType { income, expense, investment }

class Transaction {
  final String id;
  final double amount; // Changed from double? to double (Safety)
  final TransactionType type; // Changed from String to Enum (Safety)
  final String categoryName; // Changed from String? to String (Safety)
  final String categoryIcon;
  final DateTime date;
  final String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.categoryIcon = '📝',
    required this.date,
    this.note,
  });

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString(), // Save Enum as String
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  // Create from JSON map
  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Helper to parse Enum
    TransactionType parseType(String? str) {
      return TransactionType.values.firstWhere(
            (e) => e.toString() == str,
        orElse: () => TransactionType.expense, // Default fallback
      );
    }

    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: parseType(json['type']),
      categoryName: json['categoryName'] ?? 'Unknown',
      categoryIcon: json['categoryIcon'] ?? '📝',
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}
