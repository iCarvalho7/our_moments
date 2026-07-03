import '../entity/bucket_item.dart';

abstract class BucketListRepository {
  Stream<List<BucketItem>> watch(String timelineId);

  Future<void> add(String timelineId, BucketItem item);

  Future<void> toggle(String timelineId, String id, bool done);

  Future<void> remove(String timelineId, String id);
}
