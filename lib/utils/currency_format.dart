import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/preferences_provider.dart';

class CurrencyFormat {
  /// Full currency format, e.g. "₹ 1,25,000" or "₹ 1,25,000.00"
  /// - Respects user currency symbol
  /// - Respects "force decimals" toggle in PreferencesProvider
  static String format(BuildContext context, double amount) {
    final prefs = context.watch<PreferencesProvider>();
    final String symbol = prefs.currencySymbol;

    // If user wants strict accounting style, always show 2 decimals.
    // Otherwise, show 0 for whole numbers and 2 for fractional values.
    final int decimalDigits = prefs.forceDecimals
        ? 2
        : (amount % 1 == 0 ? 0 : 2);

    final formatter = NumberFormat.currency(
      locale: 'en_US',      // keep standard grouping 1,000.00
      symbol: '$symbol ',   // symbol plus space, e.g. "₹ "
      decimalDigits: decimalDigits,
    );

    return formatter.format(amount);
  }

  /// Compact Indian-style format for large numbers:
  /// 15K, 3.2L, 1.5Cr, with currency symbol (₹15L, ₹3.2Cr)
  ///
  /// NOTE: This intentionally ignores `forceDecimals` because
  /// compact values usually look better with at most 1 decimal.
  static String formatCompact(BuildContext context, double amount) {
    final prefs = context.watch<PreferencesProvider>();
    final String symbol = prefs.currencySymbol;

    final double v = amount.abs();
    String suffix;
    double divisor;

    if (v >= 10000000) {
      // Crore
      suffix = 'Cr';
      divisor = 10000000;
    } else if (v >= 100000) {
      // Lakh
      suffix = 'L';
      divisor = 100000;
    } else if (v >= 1000) {
      // Thousand
      suffix = 'K';
      divisor = 1000;
    } else {
      // For small numbers, just use the normal formatter
      return format(context, amount);
    }

    final double compact = v / divisor;
    final bool hasDecimal = (compact % 1) != 0;
    final String numberStr = hasDecimal
        ? compact.toStringAsFixed(1)   // e.g. 1.5L
        : compact.toStringAsFixed(0);  // e.g. 15L

    final String sign = amount < 0 ? '-' : '';

    return '$sign$symbol$numberStr$suffix';
  }

  /// Returns only the currency symbol, e.g. "₹", "$", "€".
  static String symbol(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    return prefs.currencySymbol;
  }
}
