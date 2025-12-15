import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'forecast_item.g.dart';

enum ForecastType {
  emiAmortized, // 0
  emiInterestOnly, // 1
  debtSimple, // 2
  goalTarget, // 3
}

@collection
class ForecastItem {
  /// Isar auto-incrementing ID.
  Id isarId = Isar.autoIncrement;

  /// String UUID (Kept unique for logic).
  @Index(unique: true)
  final String id;

  final String name;
  final String icon;

  @Enumerated(EnumType.ordinal) // Stores as 0, 1, 2...
  final ForecastType type;

  double currentOutstanding;
  double targetAmount;
  double interestRate;
  double monthlyEmiOrContribution;
  int billingDay;
  int colorValue;

  final int? categoryId;

  ForecastItem({
    this.isarId = Isar.autoIncrement,
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.currentOutstanding,
    required this.targetAmount,
    this.interestRate = 0,
    this.monthlyEmiOrContribution = 0,
    this.billingDay = 1,
    required this.colorValue,
    this.categoryId,
  });

  bool get isLiability => type.index <= 2;

  // Ignore: Isar doesn't store getters/functions, which is fine.
  @ignore
  Color get color => Color(colorValue);

  ForecastItem copyWith({
    Id? isarId,
    String? id,
    String? name,
    String? icon,
    ForecastType? type,
    double? currentOutstanding,
    double? targetAmount,
    double? interestRate,
    double? monthlyEmiOrContribution,
    int? billingDay,
    int? colorValue,
    int? categoryId,
  }) {
    return ForecastItem(
      isarId: isarId ?? this.isarId,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      currentOutstanding: currentOutstanding ?? this.currentOutstanding,
      targetAmount: targetAmount ?? this.targetAmount,
      interestRate: interestRate ?? this.interestRate,
      monthlyEmiOrContribution:
      monthlyEmiOrContribution ?? this.monthlyEmiOrContribution,
      billingDay: billingDay ?? this.billingDay,
      colorValue: colorValue ?? this.colorValue,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  // ─── LEGACY JSON SUPPORT ───

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.index,
      'currentOutstanding': currentOutstanding,
      'targetAmount': targetAmount,
      'interestRate': interestRate,
      'monthlyEmiOrContribution': monthlyEmiOrContribution,
      'billingDay': billingDay,
      'colorValue': colorValue,
      'categoryId': categoryId,
    };
  }

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: ForecastType.values[json['type'] as int],
      currentOutstanding: (json['currentOutstanding'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      monthlyEmiOrContribution:
      (json['monthlyEmiOrContribution'] as num).toDouble(),
      billingDay: (json['billingDay'] as num?)?.toInt() ?? 1,
      colorValue: json['colorValue'] as int,
      categoryId: json['categoryId'] as int?,
    );
  }
}
