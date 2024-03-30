import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/infra/data_source/moments_data_source.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

import '../../domain/entity/time_line.dart';
import '../data_source/time_line_data_source.dart';
import '../model/time_line_model.dart';

@Injectable(as: TimeLineRepository)
class TimeLineRepositoryImpl extends TimeLineRepository {
  final MomentsDataSource momentsDataSource;
  final TimeLineDataSource timeLineDataSource;

  TimeLineRepositoryImpl({
    required this.momentsDataSource,
    required this.timeLineDataSource,
  });

  @override
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
    required String timeLineId,
  }) async {
    if (month.isNotEmpty) {
      final result = await momentsDataSource.fetchAllMomentsByMonthAndYear(
          year, month, timeLineId);
      return result.map((e) => e.toEntity()).toList();
    } else {
      final result = await momentsDataSource.fetchAllMomentsByYear(
        year: year.toString(),
        timelineId: timeLineId,
      );
      return result.map((e) => e.toEntity()).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }

  @override
  Future<List<TimeLine>> getTimelinesIdByEmail(String email) {
    return timeLineDataSource.getTimeLinesByEmail(email);
  }

  @override
  Future<TimeLine> createTimeLine(TimeLine timeLine) {
    return timeLineDataSource
        .createTimeLine(TimeLineModel.fromEntity(timeLine));
  }

  @override
  String generateTimeLineId() {
    return timeLineDataSource.getNewKey();
  }

  @override
  Future updateTimeLineMomentIds(Moment moment) async {
    final timeLine = await timeLineDataSource.getTimeLineById(moment.timelineId);

    timeLine.momentIds.add(moment.id);

    return await timeLineDataSource.updateTimeline(
      timeLine.id,
      TimeLineModel.fromEntity(timeLine).toJson(),
    );
  }
}
