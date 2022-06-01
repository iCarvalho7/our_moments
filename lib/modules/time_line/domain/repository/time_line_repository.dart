import 'package:nossos_momentos/modules/time_line/domain/entities/moment.dart';

abstract class TimeLineRepository {
  Future<List<Moment>> getMoments({
    required int year,
    required String month,
  });
}
