import 'dart:math';

class FinancialMath {

  /// Calculates the number of months to pay off a loan
  static int calculateMonthsToPayOff(double principal, double rate, double emi) {
    if (principal <= 0) return 0;
    if (emi <= 0) return 999; // Forever

    double monthlyRate = rate / 12 / 100;

    double interestCost = principal * monthlyRate;
    if (emi <= interestCost) return 999;

    double numerator = -log(1 - (monthlyRate * principal) / emi);
    double denominator = log(1 + monthlyRate);

    return (numerator / denominator).ceil();
  }

  /// Returns the "Debt Free Date" based on months
  static DateTime getDebtFreeDate(int months) {
    final now = DateTime.now();
    if (months > 360) return now.add(const Duration(days: 365 * 30)); // Cap at 30 years
    return DateTime(now.year, now.month + months, now.day);
  }

  /// Calculates total interest you will pay until the loan closes
  static double calculateTotalInterest(double principal, double rate, double emi) {
    int months = calculateMonthsToPayOff(principal, rate, emi);
    if (months >= 999) return double.infinity;

    double totalPaid = months * emi;
    return totalPaid - principal;
  }

  // --- FIX: ADD THIS MISSING METHOD ---
  /// Calculates months to save/pay off a fixed amount (Sinking Fund / Simple Debt)
  static int calculateMonthsToSave(double targetAmount, double monthlyContribution) {
    if (monthlyContribution <= 0) return 999;
    return (targetAmount / monthlyContribution).ceil();
  }
}
