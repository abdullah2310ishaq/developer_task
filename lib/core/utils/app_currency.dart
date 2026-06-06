import 'package:intl/intl.dart';

class AppCurrency {
  AppCurrency._();

  static const String code = 'PKR';
  static const String symbol = 'Rs ';

  static final NumberFormat pkr = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 0,
  );

  static String format(num amount) => pkr.format(amount);
}
