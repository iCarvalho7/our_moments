import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/infra/model/time_line_model.dart';

abstract class TimeLineDataSource {
  Future<List<TimeLineModel>> getTimeLinesByEmail(String email);
  Future<TimeLineModel> getTimeLineById(String id);
  Future<TimeLineModel> createTimeLine(TimeLineModel timeLine);
  String getNewKey();
  Future updateTimeline(String timelineId, Map<String, dynamic> timeline);
}

@Injectable(as: TimeLineDataSource)
class FirebaseTimelineRemoteDataSourceImpl extends TimeLineDataSource {

  final CollectionReference<TimeLineModel> timelineRef;

  FirebaseTimelineRemoteDataSourceImpl(@Named('timeline') this.timelineRef);

  @override
  Future<List<TimeLineModel>> getTimeLinesByEmail(String email) async {
    final result = await timelineRef.where('emails', arrayContains: email).get();
    return result.docs.map((e) => e.data()).toList();
  }

  @override
  Future<TimeLineModel> createTimeLine(TimeLineModel timeLine) async {

    await timelineRef.doc(timeLine.id).set(timeLine);

    return (await timelineRef.doc(timeLine.id).get()).data()!;
  }

  @override
  String getNewKey() {
    return timelineRef.doc().id;
  }

  @override
  Future updateTimeline(String timelineId, Map<String, dynamic> timeline) async {
    await timelineRef.doc(timelineId).update(timeline);
  }

  @override
  Future<TimeLineModel> getTimeLineById(String id) async {
    return (await timelineRef.doc(id).get()).data()!;
  }
}