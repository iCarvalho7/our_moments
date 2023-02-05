
import '../../../moment/domain/entities/moment.dart';

abstract class TimeLineRepository {
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
  });
}
