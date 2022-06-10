import 'package:intl/intl.dart';

mixin DateUtil {
  static String getFormattedDate(DateTime date) =>
      "${date.day} de ${DateFormat(DateFormat.WEEKDAY).format(date)} de ${date.year}";
}

