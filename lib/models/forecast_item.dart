import 'package:flutter/material.dart';

// Defined here so AddForecastItemDialog can see it
enum ForecastType {
  debtMelting,      // 0: Liability
  debtInterestOnly, // 1: Liability
  debtSimple,       // 2: Liability
  goalTarget,       // 3: Asset
}

class ForecastItem {
  final String id;
  final String name;
  final String icon;
  final ForecastType type;

  double currentAmount;
  double targetAmount;

  double interestRate;
  double monthlyPayment;

  int colorValue;

  ForecastItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.currentAmount,
    required this.targetAmount,
    this.interestRate = 0,
    this.monthlyPayment = 0,
    required this.colorValue,
  });

  // Getter to check if it is a liability (Types 0, 1, 2)
  bool get isLiability => type.index <= 2;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.index, // Save Enum as Integer
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'interestRate': interestRate,
      'monthlyPayment': monthlyPayment,
      'colorValue': colorValue,
    };
  }

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: ForecastType.values[json['type']], // Load Integer to Enum
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
      colorValue: json['colorValue'],
    );
  }
}
