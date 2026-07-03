import '../entity/time_capsule.dart';

abstract class TimeCapsuleRepository {
  Stream<List<TimeCapsule>> watch(String timelineId);

  /// Adds a capsule and returns the generated Firestore document id.
  Future<String> add(String timelineId, TimeCapsule capsule);

  Future<void> remove(String timelineId, String id);
}
