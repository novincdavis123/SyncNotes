import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime dateTime) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(dateTime.toLocal());
  }
}
