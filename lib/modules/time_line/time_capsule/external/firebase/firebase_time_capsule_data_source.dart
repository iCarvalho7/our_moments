import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/logging/request_logger.dart';
import '../../../bucket_list/external/firebase/firebase_bucket_list_data_source.dart';
import '../../infra/data_source/time_capsule_data_source.dart';
import '../../infra/model/time_capsule_model.dart';

@Injectable(as: TimeCapsuleDataSource)
class FirebaseTimeCapsuleDataSource extends TimeCapsuleDataSource {
  final CollectionReference<Map<String, dynamic>> timeLineRef;

  FirebaseTimeCapsuleDataSource(
    @Named(FirebaseBucketListDataSource.timeLineRawCollectionParam)
    this.timeLineRef,
  );

  static const String timeCapsulesCollection = 'time_capsules';

  CollectionReference<Map<String, dynamic>> _capsulesRef(String timelineId) =>
      timeLineRef.doc(timelineId).collection(timeCapsulesCollection);

  @override
  Stream<List<TimeCapsuleModel>> watch(String timelineId) {
    return _capsulesRef(timelineId)
        .orderBy('reveal_date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeCapsuleModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> add(String timelineId, TimeCapsuleModel capsule) =>
      RequestLogger.track(
        'TimeCapsule.add',
        params: {'timelineId': timelineId, 'to': capsule.toEmail},
        request: () async {
          final ref = await _capsulesRef(timelineId).add(capsule.toJson());
          return ref.id;
        },
      );

  @override
  Future<void> remove(String timelineId, String id) => RequestLogger.track(
        'TimeCapsule.remove',
        params: {'timelineId': timelineId, 'id': id},
        request: () => _capsulesRef(timelineId).doc(id).delete(),
      );
}
