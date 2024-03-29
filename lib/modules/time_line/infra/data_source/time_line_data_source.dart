import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/infra/model/time_line_model.dart';

abstract class TimeLineDataSource {
  Future<List<TimeLineModel>> getTimeLinesByEmail(String email);
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
}