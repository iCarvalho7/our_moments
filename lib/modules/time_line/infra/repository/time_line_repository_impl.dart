import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/infra/data_source/moments_data_source.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

import '../../domain/entity/time_line.dart';
import '../data_source/time_line_data_source.dart';
import '../model/time_line_model.dart';

@Injectable(as: TimeLineRepository)
class TimeLineRepositoryImpl extends TimeLineRepository {
  final MomentsDataSource momentsDataSource;
  final TimeLineDataSource timeLineDataSource;

  TimeLineRepositoryImpl({
    required this.momentsDataSource,
    required this.timeLineDataSource,
  });

  @override
  Future<List<Moment>> getMoments({
    required String year,
    required String month,
    required String timeLineId,
  }) async {
    if (month.isNotEmpty) {
      final result = await momentsDataSource.fetchAllMomentsByMonthAndYear(year, month, timeLineId);
      return result.map((e) => e.toEntity()).toList();
    } else {
      final result = await momentsDataSource.fetchAllMomentsByYear(
        year: year.toString(),
        timelineId: timeLineId,
      );
      return result.map((e) => e.toEntity()).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }

  @override
  Future<List<TimeLine>> getTimelinesIdByEmail(String email) {
    return timeLineDataSource.getTimeLinesByEmail(email);
  }

  @override
  Future<TimeLine> createTimeLine(TimeLine timeLine) {
    return timeLineDataSource.createTimeLine(TimeLineModel.fromEntity(timeLine));
  }

  @override
  String generateTimeLineId() {
    return timeLineDataSource.getNewKey();
  }

  @override
  Future updateTimeLineMomentIds(Moment moment) async {
    final timeLine = await timeLineDataSource.getTimeLineById(moment.timelineId);

    timeLine.momentIds.add(moment.id);

    return await timeLineDataSource.updateTimeline(
      timeLine.id,
      TimeLineModel.fromEntity(timeLine).toJson(),
    );
  }

  @override
  Future<List<Moment>> getMomentsByDate({
    required DateTime endDate,
    required DateTime startDate,
    required String timeLineId,
  }) {
    return momentsDataSource.fetchMomentsByDate(
      endDate: endDate,
      startDate: startDate,
      timelineId: timeLineId,
    );
  }

  @override
  Future<TimeLine> updateTimeLineEmails(TimeLine timeline, String email) async {
    timeline.emails.add(email);

    return timeLineDataSource.updateTimeline(
      timeline.id,
      TimeLineModel.fromEntity(timeline).toJson(),
    );
  }

  @override
  Future<TimeLine> removeTimeLineMember(TimeLine timeline, String email) {
    final emails = timeline.emails.where((e) => e != email).toList();
    final roles = Map<String, String>.from(timeline.roles)..remove(email);
    final nicknames = Map<String, String>.from(timeline.nicknames)..remove(email);
    final owners = timeline.owners.where((e) => e != email).toList();
    return _persist(timeline.copyWith(
      emails: emails,
      roles: roles,
      nicknames: nicknames,
      owners: owners,
    ));
  }

  @override
  Future<TimeLine> getTimeLineById(String id) {
    return timeLineDataSource.getTimeLineById(id);
  }

  @override
  Future<TimeLine> updateRelationshipStartDate(TimeLine timeline, DateTime date) =>
      _persist(timeline.copyWith(relationshipStartDate: date));

  @override
  Future<TimeLine> updateRelationshipEndDate(TimeLine timeline, DateTime? date,
      {bool enforceEndDate = true}) {
    // `date` is intentionally nullable (null clears the end date), so it is set
    // explicitly rather than through copyWith's null-coalescing.
    return _persist(TimeLine(
      createdDate: timeline.createdDate,
      emails: timeline.emails,
      id: timeline.id,
      momentIds: timeline.momentIds,
      owners: timeline.owners,
      relationshipStartDate: timeline.relationshipStartDate,
      relationshipEndDate: date,
      name: timeline.name,
      accentColor: timeline.accentColor,
      isPremium: timeline.isPremium,
      premiumUntil: timeline.premiumUntil,
      coverPhotoUrl: timeline.coverPhotoUrl,
      nicknames: timeline.nicknames,
      enforceEndDate: enforceEndDate,
      roles: timeline.roles,
      momentEditPolicy: timeline.momentEditPolicy,
      pendingDeletion: timeline.pendingDeletion,
    ));
  }

  @override
  Future<TimeLine> updateTimeLineDetails(
    TimeLine timeline, {
    required String name,
    int? accentColor,
  }) {
    // `accentColor` is intentionally nullable (null clears the accent), so it is
    // set explicitly rather than through copyWith's null-coalescing.
    final updated = timeline.copyWith(name: name);
    return _persist(TimeLine(
      createdDate: updated.createdDate,
      emails: updated.emails,
      id: updated.id,
      momentIds: updated.momentIds,
      owners: updated.owners,
      relationshipStartDate: updated.relationshipStartDate,
      relationshipEndDate: updated.relationshipEndDate,
      name: updated.name,
      accentColor: accentColor,
      isPremium: updated.isPremium,
      premiumUntil: updated.premiumUntil,
      coverPhotoUrl: updated.coverPhotoUrl,
      nicknames: updated.nicknames,
      enforceEndDate: updated.enforceEndDate,
      roles: updated.roles,
      momentEditPolicy: updated.momentEditPolicy,
      pendingDeletion: updated.pendingDeletion,
    ));
  }

  @override
  Future<TimeLine> updateTimeLinePremium(
    TimeLine timeline, {
    required bool isPremium,
    DateTime? premiumUntil,
  }) {
    // `premiumUntil` is intentionally nullable (null means lifetime), so it is
    // set explicitly rather than through copyWith's null-coalescing — otherwise
    // a previous expiry date would stick when switching to a lifetime plan.
    final updated = timeline.copyWith(isPremium: isPremium);
    return _persist(TimeLine(
      createdDate: updated.createdDate,
      emails: updated.emails,
      id: updated.id,
      momentIds: updated.momentIds,
      owners: updated.owners,
      relationshipStartDate: updated.relationshipStartDate,
      relationshipEndDate: updated.relationshipEndDate,
      name: updated.name,
      accentColor: updated.accentColor,
      isPremium: updated.isPremium,
      premiumUntil: premiumUntil,
      coverPhotoUrl: updated.coverPhotoUrl,
      nicknames: updated.nicknames,
      enforceEndDate: updated.enforceEndDate,
      roles: updated.roles,
      momentEditPolicy: updated.momentEditPolicy,
      pendingDeletion: updated.pendingDeletion,
    ));
  }

  @override
  Future<TimeLine> updateCoupleHeader(
    TimeLine timeline, {
    required String coverPhotoUrl,
    required Map<String, String> nicknames,
  }) =>
      _persist(timeline.copyWith(coverPhotoUrl: coverPhotoUrl, nicknames: nicknames));

  @override
  Future<TimeLine> updateRoles(
    TimeLine timeline,
    Map<String, String> roles,
  ) {
    // Keep the `owners` list in sync with the roles map, since the Firestore
    // security rules gate timeline deletion on `owners`.
    final owners = roles.entries
        .where((e) => e.value == 'owner')
        .map((e) => e.key)
        .toList();
    return _persist(timeline.copyWith(roles: roles, owners: owners));
  }

  @override
  Future<TimeLine> updatePendingDeletion(
    TimeLine timeline,
    Map<String, bool>? pendingDeletion,
  ) {
    // `pendingDeletion` is intentionally nullable (null clears the consensus),
    // so it is set explicitly rather than through copyWith's null-coalescing.
    return _persist(TimeLine(
      createdDate: timeline.createdDate,
      emails: timeline.emails,
      id: timeline.id,
      momentIds: timeline.momentIds,
      owners: timeline.owners,
      relationshipStartDate: timeline.relationshipStartDate,
      relationshipEndDate: timeline.relationshipEndDate,
      name: timeline.name,
      accentColor: timeline.accentColor,
      isPremium: timeline.isPremium,
      premiumUntil: timeline.premiumUntil,
      coverPhotoUrl: timeline.coverPhotoUrl,
      nicknames: timeline.nicknames,
      enforceEndDate: timeline.enforceEndDate,
      roles: timeline.roles,
      momentEditPolicy: timeline.momentEditPolicy,
      pendingDeletion: pendingDeletion,
    ));
  }

  @override
  Future<void> deleteTimeLine(String timelineId) {
    return timeLineDataSource.deleteTimeLine(timelineId);
  }

  /// Round-trips the whole [TimeLine] through [TimeLineModel] and writes it,
  /// so every field is preserved on partial updates. Returns the written model.
  Future<TimeLine> _persist(TimeLine timeline) async {
    final model = TimeLineModel.fromEntity(timeline);
    await timeLineDataSource.updateTimeline(model.id, model.toJson());
    return model;
  }
}
