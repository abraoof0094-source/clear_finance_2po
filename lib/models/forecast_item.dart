import 'package:flutter/material.dart';

/// How a forecast item behaves over time.
///
/// Index 0–2 are liabilities (money you owe).
/// Index 3 is an asset/goal (money you are building up).
enum ForecastType {
  /// Amortizing EMI loan where each EMI has interest + principal.
  emiAmortized,     // 0: Liability (Car/Home EMI)

  /// Interest-only debt (principal not reduced by regular payments).
  emiInterestOnly,  // 1: Liability (Gold loan / interest-led)

  /// Simple debt without detailed EMI schedule.
  debtSimple,       // 2: Liability (personal debt, ad-hoc payments)

  /// Savings/investment goal with a target amount.
  goalTarget,       // 3: Asset (Emergency fund, Opportunity fund, Goals)
}

/// A long-term item shown in the Forecast screen (loan or goal).
///
/// - For liabilities, [currentOutstanding] is outstanding balance.
/// - For goals, [currentOutstanding] is how much you’ve accumulated so far.
/// - [interestRate] and [monthlyEmiOrContribution] are used for projections.
/// - [billingDay] is the usual EMI / contribution date (1–28).
/// - [colorValue] stores a color value for consistent theming.
/// - [categoryId] (optional) links this forecast item to a category used by transactions.
class ForecastItem {
  /// String identifier (e.g. UUID or timestamp-based).
  final String id;

  /// Display name, e.g. "Home loan" or "Emergency fund".
  final String name;

  /// Emoji or short icon, e.g. "🏠", "🏦".
  final String icon;

  /// Behavior type (see [ForecastType] docs above).
  final ForecastType type;

  /// Current outstanding amount (for debts) or current saved amount (for goals).
  double currentOutstanding;

  /// For debts: original principal or target payoff.
  /// For goals: target amount to reach.
  double targetAmount;

  /// Annual interest rate in percent (e.g. 10 for 10%), if applicable.
  double interestRate;

  /// Planned monthly EMI or monthly contribution (0 allowed).
  ///
  /// Used for projections and to detect “EMI-like” payments by amount.
  double monthlyEmiOrContribution;

  /// Usual EMI / contribution date in month (1–28).
  ///
  /// Used only for projection timeline, not for classifying payments.
  int billingDay;

  /// ARGB color value used to style cards/charts.
  int colorValue;

  /// Optional link back to the category this item is based on.
  ///
  /// When a transaction is added in a Goal/Invest/Liability category, you can:
  /// - Find or create a [ForecastItem] with this [categoryId].
  /// - Update [currentOutstanding] so Forecast always reflects real cashflows.
  final int? categoryId;

  ForecastItem({
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

  /// True if this item represents a liability (debt).
  ///
  /// By convention, the first three ForecastType values are debts.
  bool get isLiability => type.index <= 2;

  /// Convenience getter to build a Color from [colorValue] when needed.
  Color get color => Color(colorValue);

  /// Create a copy with some fields changed (used to attach categoryId or edit values).
  ForecastItem copyWith({
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

  /// Serialize to JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.index, // Save enum as integer index.
      'currentOutstanding': currentOutstanding,
      'targetAmount': targetAmount,
      'interestRate': interestRate,
      'monthlyEmiOrContribution': monthlyEmiOrContribution,
      'billingDay': billingDay,
      'colorValue': colorValue,
      'categoryId': categoryId,
    };
  }

  /// Construct a ForecastItem from a JSON map.
  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: ForecastType.values[json['type'] as int], // Integer → enum.
      currentOutstanding: (json['currentOutstanding'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      monthlyEmiOrContribution:
      (json['monthlyEmiOrContribution'] as num).toDouble(),
      billingDay: (json['billingDay'] as num?)?.toInt() ?? 1,
      colorValue: json['colorValue'] as int,
      categoryId: json['categoryId'] as int?, // nullable
    );
  }
}