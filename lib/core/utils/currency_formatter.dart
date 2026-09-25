import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    return NumberFormat.compactCurrency(symbol: '\$').format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
