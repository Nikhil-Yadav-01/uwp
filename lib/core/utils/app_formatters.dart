/// Reusable Value & Text Formatter Utility
class AppFormatters {
  AppFormatters._();

  /// Centralized currency symbol for the application
  static const String currencySymbol = '₹';

  /// Formats numbers to currency string, e.g. 1250.5 -> "₹1,250.50"
  static String currency(num amount, {String symbol = currencySymbol}) {
    return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Compact number formatter, e.g. 15400 -> "15.4K", 2500000 -> "2.5M"
  static String compactNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Capitalizes first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
