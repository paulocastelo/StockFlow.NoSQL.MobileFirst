import 'package:intl/intl.dart';

String formatDateTime(String utcString) {
  final dt = DateTime.parse(utcString).toLocal();
  return DateFormat('MMM d, y  h:mm a').format(dt);
}

String formatCurrency(double value) {
  return NumberFormat.currency(symbol: r'$').format(value);
}
