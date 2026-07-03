import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/utils/logging/request_logger.dart';
import 'package:nossos_momentos/modules/time_line/infra/model/time_line_model.dart';

abstract class TimeLineDataSource {
  Future<List<TimeLineModel>> getTimeLinesByEmail(String email);
  Future<TimeLineModel> getTimeLineById(String id);
  Future<TimeLineModel> createTimeLine(TimeLineModel timeLine);
  String getNewKey();
  Future<TimeLineModel> updateTimeline(String timelineId, Map<String, dynamic> timeline);
  Future<void> deleteTimeLine(String timelineId);
}

@Injectable(as: TimeLineDataSource)
class FirebaseTimelineRemoteDataSourceImpl extends TimeLineDataSource {

  final CollectionReference<TimeLineModel> timelineRef;

  FirebaseTimelineRemoteDataSourceImpl(@Named('timeline') this.timelineRef);

  @override
  Future<List<TimeLineModel>> getTimeLinesByEmail(String email) => RequestLogger.track(
        'TimeLine.getTimeLinesByEmail',
        params: {'email': email},
        request: () async {
          final result = await timelineRef.where('emails', arrayContains: email).get();
          return result.docs.map((e) => e.data()).toList();
        },
      );

  @override
  Future<TimeLineModel> createTimeLine(TimeLineModel timeLine) => RequestLogger.track(
        'TimeLine.createTimeLine',
        params: {'timelineId': timeLine.id},
        request: () async {
          await timelineRef.doc(timeLine.id).set(timeLine);

          return (await timelineRef.doc(timeLine.id).get()).data()!;
        },
      );

  @override
  String getNewKey() {
    return timelineRef.doc().id;
  }

  @override
  Future<TimeLineModel> updateTimeline(String timelineId, Map<String, dynamic> timeline) => RequestLogger.track(
        'TimeLine.updateTimeline',
        params: {'timelineId': timelineId, 'fields': timeline.keys.join('/')},
        request: () async {
          await timelineRef.doc(timelineId).update(timeline);

          return (await timelineRef.doc(timelineId).get()).data()!;
        },
      );

  @override
  Future<TimeLineModel> getTimeLineById(String id) => RequestLogger.track(
        'TimeLine.getTimeLineById',
        params: {'id': id},
        request: () async => (await timelineRef.doc(id).get()).data()!,
      );

  @override
  Future<void> deleteTimeLine(String timelineId) => RequestLogger.track(
        'TimeLine.deleteTimeLine',
        params: {'timelineId': timelineId},
        request: () => timelineRef.doc(timelineId).delete(),
      );
}