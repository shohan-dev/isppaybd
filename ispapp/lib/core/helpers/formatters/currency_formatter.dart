import 'package:intl/intl.dart';

class SCurrencyFormatter {
  /// Formats a given number into a currency format based on the [locale]
  /// Example: 1234.56 -> $1,234.56 (For USD)
  static String formatCurrency(
    double amount, {
    String locale = 'en_US',
    String symbol = '\$',
    int decimalDigits = 2,
  }) {
    try {
      final NumberFormat currencyFormat = NumberFormat.currency(
        locale: locale,
        symbol: symbol,
        decimalDigits: decimalDigits,
      );
      return currencyFormat.format(amount);
    } catch (e) {
      print("Error formatting currency: $e");
      return '$symbol$amount'; // Fallback in case of error
    }
  }

  /// Formats a given number into currency format, using default locale and currency symbol.
  /// Example: 1234.56 -> ₹1,234.56 (For INR)
  static String formatCurrencyDefault(double amount) {
    return formatCurrency(amount, locale: 'en_IN', symbol: '₹');
  }

  /// Converts a currency formatted string back to a double.
  /// Example: "$1,234.56" -> 1234.56
  static num parseCurrency(String formattedAmount) {
    try {
      final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US',
      );
      return currencyFormat.parse(formattedAmount);
    } catch (e) {
      print("Error parsing currency: $e");
      return 0.0; // Fallback in case of error
    }
  }
}
