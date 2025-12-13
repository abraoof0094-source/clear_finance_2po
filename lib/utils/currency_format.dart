import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

class CurrencyFormat {

  /// Formats a double (e.g., 1250.50) into a localized currency string.
  /// Example outputs: "₹ 1,250.50", "$ 1,250", "€ 500"
  ///
  /// Uses [context.watch] so any widget using this will auto-rebuild
  /// if the user changes currency settings.
  static String format(BuildContext context, double amount) {
    // 1. Get the symbol from your provider
    final prefs = context.watch<PreferencesProvider>();
    final String symbol = prefs.currencySymbol;

    // 2. Determine decimal places:
    // If the number is whole (e.g. 100.0), show 0 decimals.
    // If it has cents (e.g. 100.50), show 2 decimals.
    final int decimalDigits = (amount % 1 == 0) ? 0 : 2;

    // 3. Create the formatter
    final formatter = NumberFormat.currency(
      locale: 'en_US',       // We keep English format (1,000.00) for consistency
      symbol: '$symbol ',    // Add a space for better readability (e.g. "₹ ")
      decimalDigits: decimalDigits,
    );

    return formatter.format(amount);
  }

  /// Returns just the currency symbol (e.g., "₹", "$", "€").
  /// Useful for prefix text in InputFields.
  static String symbol(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    return prefs.currencySymbol;
  }
}
