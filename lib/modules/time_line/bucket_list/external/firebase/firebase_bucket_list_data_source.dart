import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/logging/request_logger.dart';
import '../../infra/data_source/bucket_list_data_source.dart';
import '../../infra/model/bucket_item_model.dart';

@Injectable(as: BucketListDataSource)
class FirebaseBucketListDataSource extends BucketListDataSource {
  final CollectionReference<Map<String, dynamic>> timeLineRef;

  FirebaseBucketListDataSource(
    @Named(timeLineRawCollectionParam) this.timeLineRef,
  );

  static const String timeLineRawCollectionParam = 'timeLineRawCollectionParam';
  static const String bucketListCollection = 'bucket_list';

  CollectionReference<Map<String, dynamic>> _bucketRef(String timelineId) =>
      timeLineRef.doc(timelineId).collection(bucketListCollection);

  @override
  Stream<List<BucketItemModel>> watch(String timelineId) {
    return _bucketRef(timelineId)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BucketItemModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> add(String timelineId, BucketItemModel item) => RequestLogger.track(
        'BucketList.add',
        params: {'timelineId': timelineId, 'title': item.title},
        request: () => _bucketRef(timelineId).add(item.toJson()),
      );

  @override
  Future<void> toggle(String timelineId, String id, bool done) => RequestLogger.track(
        'BucketList.toggle',
        params: {'timelineId': timelineId, 'id': id, 'done': done},
        request: () => _bucketRef(timelineId).doc(id).update({'done': done}),
      );

  @override
  Future<void> remove(String timelineId, String id) => RequestLogger.track(
        'BucketList.remove',
        params: {'timelineId': timelineId, 'id': id},
        request: () => _bucketRef(timelineId).doc(id).delete(),
      );
}
