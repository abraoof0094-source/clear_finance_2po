import 'dart:math';

class FinancialMath {
  /// Calculates the number of months to pay off an amortizing EMI loan.
  ///
  /// [principal]  → current outstanding.
  /// [rate]       → annual interest rate in percent (e.g. 10 for 10%).
  /// [emi]        → planned fixed monthly EMI.
  ///
  /// Returns 999 as a sentinel for "effectively never" (EMI too small).
  static int calculateMonthsToPayOff(
      double principal,
      double rate,
      double emi,
      ) {
    if (principal <= 0) return 0;
    if (emi <= 0) return 999; // Forever

    final monthlyRate = rate / 12 / 100;

    final interestCost = principal * monthlyRate;
    if (emi <= interestCost) return 999;

    final numerator = -log(1 - (monthlyRate * principal) / emi);
    final denominator = log(1 + monthlyRate);

    return (numerator / denominator).ceil();
  }

  /// Returns the "Debt Free Date" based on [months] from now.
  ///
  /// Caps at 30 years to avoid absurd dates when math says "never".
  static DateTime getDebtFreeDate(int months) {
    final now = DateTime.now();
    if (months > 360) {
      return now.add(const Duration(days: 365 * 30)); // Cap at 30 years
    }
    return DateTime(now.year, now.month + months, now.day);
  }

  /// Calculates total interest you will pay until the loan closes,
  /// using the same assumptions as [calculateMonthsToPayOff].
  static double calculateTotalInterest(
      double principal,
      double rate,
      double emi,
      ) {
    final months = calculateMonthsToPayOff(principal, rate, emi);
    if (months >= 999) return double.infinity;

    final totalPaid = months * emi;
    return totalPaid - principal;
  }

  /// Calculates months to save/pay off a fixed amount (Sinking Fund / Simple Debt)
  /// with no interest (or ignoring interest).
  static int calculateMonthsToSave(
      double targetAmount,
      double monthlyContribution,
      ) {
    if (monthlyContribution <= 0) return 999;
    if (targetAmount <= 0) return 0;
    return (targetAmount / monthlyContribution).ceil();
  }

  /// Approximate monthly interest for a given outstanding amount.
  ///
  /// Helpful when splitting an EMI into interest + principal for the current month.
  static double calculateMonthlyInterest(
      double outstanding,
      double annualRatePercent,
      ) {
    if (outstanding <= 0 || annualRatePercent <= 0) return 0;
    final monthlyRate = annualRatePercent / 12 / 100;
    return outstanding * monthlyRate;
  }

  /// Given an EMI and this month's interest, returns the principal portion.
  ///
  /// If EMI is too small to even cover interest, principal part is 0.
  static double calculateEmiPrincipalPortion(
      double emi,
      double monthlyInterest,
      ) {
    final principalPart = emi - monthlyInterest;
    if (principalPart <= 0) return 0;
    return principalPart;
  }
}
