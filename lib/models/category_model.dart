import 'package:flutter/material.dart';

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

class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final CategoryBucket bucket;
  final bool isDefault;

  /// If true, this category is treated as a monthly mandate/essential.
  final bool isMandate;

  /// Planned monthly amount for this mandate (used for Safe to spend etc.).
  /// Null when [isMandate] is false or user has not set a value.
  final double? monthlyMandate;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.bucket,
    required this.isDefault,
    this.isMandate = false,
    this.monthlyMandate,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    CategoryBucket? bucket,
    bool? isDefault,
    bool? isMandate,
    double? monthlyMandate,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      bucket: bucket ?? this.bucket,
      isDefault: isDefault ?? this.isDefault,
      isMandate: isMandate ?? this.isMandate,
      monthlyMandate: monthlyMandate ?? this.monthlyMandate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'bucket': bucket.index,
      'isDefault': isDefault,
      'isMandate': isMandate,
      'monthlyMandate': monthlyMandate,
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
    );
  }
}
