import 'package:intl/intl.dart';

mixin DateUtil {
  static String getFormattedDate(DateTime date) =>
      "${date.day} ${DateFormat(DateFormat.MONTH, 'pt_BR').format(date)} de ${date.year}";
}

