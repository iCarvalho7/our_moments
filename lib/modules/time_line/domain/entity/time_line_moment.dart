
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';

class TimeLineMoment {
  final String id;
  final String title;
  final String body;
  final MomentType type;

  const TimeLineMoment({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
  });
}
