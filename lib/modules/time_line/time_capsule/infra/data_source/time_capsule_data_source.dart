import '../model/time_capsule_model.dart';

abstract class TimeCapsuleDataSource {
  Stream<List<TimeCapsuleModel>> watch(String timelineId);

  /// Adds a capsule and returns the generated Firestore document id.
  Future<String> add(String timelineId, TimeCapsuleModel capsule);

  Future<void> remove(String timelineId, String id);
}
