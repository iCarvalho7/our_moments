
import '../../../moment/domain/entities/moment.dart';
import '../entity/time_line.dart';

abstract class TimeLineRepository {
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
  });

  Future<List<TimeLine>> getTimelinesIdByEmail(String email);
}
