import 'package:flutter/material.dart';

enum CategoryType { income, expense, investment }
enum CategoryNature { fixed, variable }

class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final CategoryType type;
  final double amount;
  final CategoryNature nature;
  final Color color;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.amount = 0.0,
    this.nature = CategoryNature.variable,
    this.color = Colors.blue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.toString(),
      'amount': amount,
      'nature': nature.toString(),
      'color': color.value,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    CategoryType parseType(String str) {
      return CategoryType.values.firstWhere(
            (e) => e.toString() == str,
        orElse: () => CategoryType.expense,
      );
    }
    CategoryNature parseNature(String str) {
      return CategoryNature.values.firstWhere(
            (e) => e.toString() == str,
        orElse: () => CategoryNature.variable,
      );
    }

    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: parseType(json['type']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      nature: parseNature(json['nature'] ?? ''),
      color: Color(json['color'] ?? 0xFF2196F3),
    );
  }
}
