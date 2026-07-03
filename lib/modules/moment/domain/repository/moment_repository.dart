import 'dart:async';

import '../entities/moment.dart';

abstract class MomentRepository {
  Future registerMoment({required Moment moment});
  Future editMoment(Moment moment);
  FutureOr<Moment> fetchMomentById(String id);
  Future deleteMoment(String momentId);
  Future<void> deleteMomentsByTimeline(String timelineId);

  /// Every moment authored by [authorEmail] inside [timelineId].
  Future<List<Moment>> getMomentsByAuthorInTimeline(
    String timelineId,
    String authorEmail,
  );

  /// Best-effort removal of the given media (photos/audio) from Storage.
  Future<void> deleteMomentMedia(List<String> mediaUrls);
}
