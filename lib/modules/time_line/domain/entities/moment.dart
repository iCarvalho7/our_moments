import 'package:nossos_momentos/modules/time_line/domain/entities/moment_type.dart';

class Moment {
  final String id;
  final DateTime dateTime;
  final String title;
  final String body;
  final MomentType type;

  const Moment({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.body,
    required this.type,
  });
}
