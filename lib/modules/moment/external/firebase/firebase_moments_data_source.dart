import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../core/utils/logging/request_logger.dart';
import '../../../photos/external/firebase_storage_photo_data_source.dart';
import '../../infra/data_source/moments_data_source.dart';
import '../../infra/models/moment_model.dart';

@Injectable(as: MomentsDataSource)
class FirebaseMomentsDataSource extends MomentsDataSource {
  final CollectionReference<MomentModel> momentsDBRef;
  final Reference momentsPhotoRef;

  FirebaseMomentsDataSource(
    @Named(momentsDBParam) this.momentsDBRef,
    @Named(FirebaseStoragePhotoDataSource.photosStorage) this.momentsPhotoRef,
  );

  @override
  Future registerMoment({required MomentModel moment}) => RequestLogger.track(
        'Moment.registerMoment',
        params: {'momentId': moment.id},
        request: () => momentsDBRef.doc(moment.id).set(moment),
      );

  @override
  Future<MomentModel> fetchMoment({
    required String momentId,
  }) =>
      RequestLogger.track(
        'Moment.fetchMoment',
        params: {'momentId': momentId},
        request: () async {
          final result = await momentsDBRef.where('id', isEqualTo: momentId).get(const GetOptions(
                source: Source.server,
              ));

          return result.docs.first.data();
        },
      );

  @override
  Future updateMoment(String momentId, Map<String, dynamic> momentModel) => RequestLogger.track(
        'Moment.updateMoment',
        params: {'momentId': momentId, 'fields': momentModel.keys.join('/')},
        request: () => momentsDBRef.doc(momentId).update(momentModel),
      );

  @override
  Future deleteMoment(String momentId) => RequestLogger.track(
        'Moment.deleteMoment',
        params: {'momentId': momentId},
        request: () => momentsDBRef.doc(momentId).delete(),
      );

  @override
  Future<void> deleteMomentsByTimeline(String timelineId) => RequestLogger.track(
        'Moment.deleteMomentsByTimeline',
        params: {'timelineId': timelineId},
        request: () async {
          final result = await momentsDBRef
              .where('time_line_id', isEqualTo: timelineId)
              .get(const GetOptions(source: Source.server));

          // Firestore caps a batch at 500 writes, so delete in chunks.
          const chunkSize = 450;
          final docs = result.docs;
          for (var i = 0; i < docs.length; i += chunkSize) {
            final batch = momentsDBRef.firestore.batch();
            for (final doc in docs.skip(i).take(chunkSize)) {
              batch.delete(doc.reference);
            }
            await batch.commit();
          }
        },
      );

  @override
  Future<List<MomentModel>> getMomentsByAuthorInTimeline(
    String timelineId,
    String authorEmail,
  ) =>
      RequestLogger.track(
        'Moment.getMomentsByAuthorInTimeline',
        params: {'timelineId': timelineId, 'author': authorEmail},
        request: () async {
          final result = await momentsDBRef
              .where('time_line_id', isEqualTo: timelineId)
              .get(const GetOptions(source: Source.server));

          return result.docs
              .map((e) => e.data())
              .where((e) => e.author == authorEmail)
              .toList();
        },
      );

  @override
  Future<void> deleteMomentMedia(List<String> mediaUrls) => RequestLogger.track(
        'Moment.deleteMomentMedia',
        params: {'count': '${mediaUrls.length}'},
        request: () async {
          for (final url in mediaUrls) {
            if (url.isEmpty) continue;
            try {
              await FirebaseStorage.instance.refFromURL(url).delete();
            } catch (_) {
              // Best-effort: ignore missing/failed objects.
            }
          }
        },
      );

  @override
  Future<List<MomentModel>> fetchAllMomentsByMonthAndYear(
    String year,
    String month,
    String timelineId,
  ) =>
      RequestLogger.track(
        'Moment.fetchAllMomentsByMonthAndYear',
        params: {'year': year, 'month': month, 'timelineId': timelineId},
        request: () async {
          final result =
              await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

          return result.docs
              .map((e) => e.data())
              .toList()
              .where((element) => element.month == month && element.year == year)
              .toList();
        },
      );

  @override
  Future<List<MomentModel>> fetchAllMomentsByYear({
    required String year,
    required String timelineId,
  }) =>
      RequestLogger.track(
        'Moment.fetchAllMomentsByYear',
        params: {'year': year, 'timelineId': timelineId},
        request: () async {
          final result =
              await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

          return result.docs.map((e) => e.data()).where((element) => element.year == year).toList();
        },
      );

  static const String momentsDBParam = "momentsDBParam";
  static const yearQuery = 'year';
  static const monthQuery = 'month';
  static const titleParam = 'title';
  static const bodyParam = 'body';

  @override
  Future<List<MomentModel>> fetchMomentsByDate({
    required DateTime startDate,
    required DateTime endDate,
    required String timelineId,
  }) =>
      RequestLogger.track(
        'Moment.fetchMomentsByDate',
        params: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'timelineId': timelineId,
        },
        request: () async {
          final result =
              await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

          return result.docs
              .map((e) => e.data())
              .where((e) => e.dateTime.isBefore(endDate) && e.dateTime.isAfter(startDate))
              .toList();
        },
      );
}
