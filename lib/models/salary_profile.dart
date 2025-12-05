import 'dart:convert';

enum InvestmentMode { percentage, fixedAmount }

class SalaryProfile {
  final int? id;
  final double? monthlySalary;
  final double? investmentGoalPercentage;
  final InvestmentMode investmentMode;
  final double? investmentGoalAmount;

  // Added these to match previous logic if needed, otherwise they are optional
  final int? salaryDate;
  final double? emergencyFundGoal;

  SalaryProfile({
    this.id,
    this.monthlySalary,
    this.investmentGoalPercentage,
    this.investmentMode = InvestmentMode.percentage,
    this.investmentGoalAmount,
    this.salaryDate,        // Added to prevent conflicts
    this.emergencyFundGoal, // Added to prevent conflicts
  });

  // Convert to Map (Updated to include new fields)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlySalary': monthlySalary,
      'investmentGoalPercentage': investmentGoalPercentage,
      'investmentMode': investmentMode.name,
      'investmentGoalAmount': investmentGoalAmount,
      'salaryDate': salaryDate,
      'emergencyFundGoal': emergencyFundGoal,
    };
  }

  // Create from Map
  factory SalaryProfile.fromMap(Map<String, dynamic> map) {
    return SalaryProfile(
      id: map['id'],
      monthlySalary: map['monthlySalary'] != null ? (map['monthlySalary'] as num).toDouble() : null,
      investmentGoalPercentage: map['investmentGoalPercentage'] != null ? (map['investmentGoalPercentage'] as num).toDouble() : null,
      investmentMode: InvestmentMode.values.firstWhere(
            (e) => e.name == map['investmentMode'],
        orElse: () => InvestmentMode.percentage,
      ),
      investmentGoalAmount: map['investmentGoalAmount'] != null ? (map['investmentGoalAmount'] as num).toDouble() : null,
      salaryDate: map['salaryDate'],
      emergencyFundGoal: map['emergencyFundGoal'] != null ? (map['emergencyFundGoal'] as num).toDouble() : null,
    );
  }

  // --- REQUIRED FOR FINANCE PROVIDER ---
  String toJson() => json.encode(toMap());

  factory SalaryProfile.fromJson(String source) => SalaryProfile.fromMap(json.decode(source));

  // CopyWith
  SalaryProfile copyWith({
    int? id,
    double? monthlySalary,
    double? investmentGoalPercentage,
    InvestmentMode? investmentMode,
    double? investmentGoalAmount,
    int? salaryDate,
    double? emergencyFundGoal,
  }) {
    return SalaryProfile(
      id: id ?? this.id,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      investmentGoalPercentage: investmentGoalPercentage ?? this.investmentGoalPercentage,
      investmentMode: investmentMode ?? this.investmentMode,
      investmentGoalAmount: investmentGoalAmount ?? this.investmentGoalAmount,
      salaryDate: salaryDate ?? this.salaryDate,
      emergencyFundGoal: emergencyFundGoal ?? this.emergencyFundGoal,
    );
  }
}
