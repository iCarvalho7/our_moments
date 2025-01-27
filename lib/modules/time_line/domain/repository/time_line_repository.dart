
import '../../../moment/domain/entities/moment.dart';
import '../entity/time_line.dart';

abstract class TimeLineRepository {
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
    required String timeLineId,
  });

  Future<List<Moment>> getMomentsByDate({
    required DateTime startDate,
    required DateTime endDate,
    required String timeLineId,
  });

  Future<List<TimeLine>> getTimelinesIdByEmail(String email);

  Future<TimeLine> createTimeLine(TimeLine timeLine);

  String generateTimeLineId();

  Future updateTimeLineMomentIds(Moment moment);
}
