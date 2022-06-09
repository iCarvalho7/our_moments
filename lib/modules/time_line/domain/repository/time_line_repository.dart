import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

abstract class TimeLineRepository {
  Future<List<TimeLineMoment>> getMoments({
    required String year,
    required String month,
  });
}
