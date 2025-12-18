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

  /// Reverse EMI: Given principal, annual rate (%) and tenure in months,
  /// returns the fixed monthly EMI for a standard amortizing loan.
  ///
  /// Formula:
  /// EMI = P * r * (1 + r)^n / [ (1 + r)^n - 1 ]
  /// where P = principal, r = monthly rate, n = months. [web:47][web:59]
  static double calculateRequiredEmi(
      double principal,
      double annualRatePercent,
      int tenureMonths,
      ) {
    if (principal <= 0 || tenureMonths <= 0) return 0;

    final r = annualRatePercent / 12 / 100; // monthly rate

    if (r == 0) {
      // No interest: just principal / months
      return principal / tenureMonths;
    }

    final powTerm = pow(1 + r, tenureMonths);
    final numerator = principal * r * powTerm;
    final denominator = powTerm - 1;

    if (denominator == 0) return 0;

    return numerator / denominator;
  }

  /// Returns the "Debt Free Date" based on [months] from now.
  ///
  /// Uses month-end–safe arithmetic, so:
  ///  - Jan 31 + 1 month → Feb 28/29
  ///  - Mar 31 + 1 month → Apr 30
  /// Caps at 30 years to avoid absurd dates when math says "never".
  static DateTime getDebtFreeDate(int months) {
    final now = DateTime.now();
    if (months > 360) {
      return now.add(const Duration(days: 365 * 30)); // Cap at 30 years
    }
    return addMonthsSafe(now, months);
  }

  /// Month-end–safe month addition.
  ///
  /// If the original day does not exist in the target month,
  /// it clamps to the last day of that month.
  static DateTime addMonthsSafe(DateTime date, int monthsToAdd) {
    final int yearOffset = (date.month - 1 + monthsToAdd) ~/ 12;
    final int newMonthIndex = (date.month - 1 + monthsToAdd) % 12;
    final int newYear = date.year + yearOffset;
    final int newMonth = newMonthIndex + 1;

    // Last day of target month: go to first day of next month, subtract one day.
    final DateTime firstOfNextMonth =
    (newMonth == 12) ? DateTime(newYear + 1, 1, 1) : DateTime(newYear, newMonth + 1, 1);
    final int lastDayOfNewMonth =
        firstOfNextMonth.subtract(const Duration(days: 1)).day;

    final int newDay = date.day.clamp(1, lastDayOfNewMonth);

    return DateTime(newYear, newMonth, newDay);
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
