
import '../../../moment/domain/entities/moment.dart';
import '../entity/time_line.dart';

abstract class TimeLineRepository {
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
    required String timeLineId,
  });

  Future<List<Moment>> getMomentsByDate({
    required DateTime startDate,
    required DateTime endDate,
    required String timeLineId,
  });

  Future<List<TimeLine>> getTimelinesIdByEmail(String email);

  Future<TimeLine> createTimeLine(TimeLine timeLine);

  String generateTimeLineId();

  Future updateTimeLineMomentIds(Moment moment);

  Future<TimeLine> updateTimeLineEmails(TimeLine timeline, String email);

  /// Removes [email] from the timeline entirely: drops it from `emails`,
  /// `roles` and `nicknames`.
  Future<TimeLine> removeTimeLineMember(TimeLine timeline, String email);

  Future<TimeLine> getTimeLineById(String id);

  Future<TimeLine> updateRelationshipStartDate(TimeLine timeline, DateTime date);

  /// Sets or clears (when [date] is null) the relationship end date.
  Future<TimeLine> updateRelationshipEndDate(TimeLine timeline, DateTime? date,
      {bool enforceEndDate = true});

  Future<TimeLine> updateTimeLineDetails(
    TimeLine timeline, {
    required String name,
    int? accentColor,
  });

  /// Mirrors the premium entitlement onto the timeline doc (premium is the
  /// couple's). [premiumUntil] null means lifetime.
  Future<TimeLine> updateTimeLinePremium(
    TimeLine timeline, {
    required bool isPremium,
    DateTime? premiumUntil,
  });

  /// Persists the couple header (cover photo + per-email nicknames) onto the
  /// timeline doc, preserving every other field.
  Future<TimeLine> updateCoupleHeader(
    TimeLine timeline, {
    required String coverPhotoUrl,
    required Map<String, String> nicknames,
  });

  /// Updates the per-member roles map (email → 'owner' | 'editor' | 'viewer').
  Future<TimeLine> updateRoles(
    TimeLine timeline,
    Map<String, String> roles,
  );

  /// Sets or clears (when [pendingDeletion] is null) the multi-owner deletion
  /// consensus map (owner email → approved).
  Future<TimeLine> updatePendingDeletion(
    TimeLine timeline,
    Map<String, bool>? pendingDeletion,
  );

  Future<void> deleteTimeLine(String timelineId);
}
