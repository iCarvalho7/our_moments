
import '../../../moment/domain/entities/moment_type.dart';

class TimeLineMoment {
  final String id;
  final String title;
  final String body;
  final MomentType type;
  final String monthDay;
  final String month;

  const TimeLineMoment({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.monthDay,
    required this.month,
  });

  String get dateTime => "$monthDay ${month.substring(0, 3).replaceFirst(month[0], month[0].toUpperCase())}";
}
