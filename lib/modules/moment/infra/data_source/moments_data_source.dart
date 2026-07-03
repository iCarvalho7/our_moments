import '../models/moment_model.dart';

abstract class MomentsDataSource {
  Future deleteMoment(String momentId);

  /// Deletes every moment document that belongs to [timelineId] (matched by the
  /// `time_line_id` field). Used when a timeline is removed entirely.
  Future<void> deleteMomentsByTimeline(String timelineId);

  Future updateMoment(String momentId, Map<String, dynamic> momentModel);

  /// Every moment authored by [authorEmail] inside [timelineId]. Used for the
  /// LGPD "delete my moments" flow when leaving a timeline.
  Future<List<MomentModel>> getMomentsByAuthorInTimeline(
    String timelineId,
    String authorEmail,
  );

  /// Best-effort removal of media (photos/audio) from Storage given their
  /// download URLs. Errors are swallowed so a missing/failed object never
  /// blocks the surrounding deletion.
  Future<void> deleteMomentMedia(List<String> mediaUrls);

  Future registerMoment({required MomentModel moment});

  Future<MomentModel> fetchMoment({required String momentId});

  Future<List<MomentModel>> fetchAllMomentsByMonthAndYear(
    String year,
    String month,
    String timelineId,
  );

  Future<List<MomentModel>> fetchAllMomentsByYear({
    required String year,
    required String timelineId,
  });

  Future<List<MomentModel>> fetchMomentsByDate({
    required DateTime endDate,
    required DateTime startDate,
    required String timelineId,
  });
}
