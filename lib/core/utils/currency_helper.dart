import 'package:intl/intl.dart';

/// Currency helper for formatting amounts
class CurrencyHelper {
  static const String usd = 'USD';
  static const String myr = 'MYR';

  /// Format amount based on currency
  static String formatAmount(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case usd:
        return '\$';
      case myr:
        return 'RM';
      default:
        return '\$';
    }
  }

  /// Get currency code for display
  static String getCurrencyCode(String currency) {
    return currency;
  }

  /// Get currency name
  static String getCurrencyName(String currency) {
    switch (currency) {
      case usd:
        return 'US Dollar';
      case myr:
        return 'Malaysian Ringgit';
      default:
        return 'US Dollar';
    }
  }

  /// Format amount with currency code (e.g., "RM 100.00" or "$ 100.00")
  static String formatAmountWithCode(double amount, String currency) {
    final symbol = _getCurrencySymbol(currency);
    final formatted = NumberFormat('#,##0.00').format(amount);
    return '$symbol $formatted';
  }

  /// Get prefix text for input fields
  static String getPrefixText(String currency) {
    return _getCurrencySymbol(currency);
  }

  /// Get label text for input fields
  static String getLabelText(String label, String currency) {
    return '$label (${getCurrencyCode(currency)})';
  }
}
