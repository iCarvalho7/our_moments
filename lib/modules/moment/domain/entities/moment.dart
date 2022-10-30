
import 'moment_type.dart';

class Moment {
  final String id;
  final DateTime dateTime;
  final String title;
  final String body;
  final String year;
  final String month;
  final String monthDay;
  final MomentType type;
  final List<String> downloadUrlList;

  const Moment({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.body,
    required this.type,
    required this.monthDay,
    required this.month,
    required this.year,
    required this.downloadUrlList,
  });
}
