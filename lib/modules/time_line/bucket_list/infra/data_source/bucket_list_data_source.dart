import '../model/bucket_item_model.dart';

abstract class BucketListDataSource {
  Stream<List<BucketItemModel>> watch(String timelineId);

  Future<void> add(String timelineId, BucketItemModel item);

  Future<void> toggle(String timelineId, String id, bool done);

  Future<void> remove(String timelineId, String id);
}
