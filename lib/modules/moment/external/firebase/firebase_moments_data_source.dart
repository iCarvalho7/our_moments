import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
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
  Future registerMoment({required MomentModel moment}) => momentsDBRef.doc(moment.id).set(moment);

  @override
  Future<MomentModel> fetchMoment({
    required String momentId,
  }) async {
    final result = await momentsDBRef.where('id', isEqualTo: momentId).get(const GetOptions(
          source: Source.server,
        ));

    return result.docs.first.data();
  }

  @override
  Future updateMoment(String momentId, Map<String, dynamic> momentModel) async {
    return await momentsDBRef.doc(momentId).update(momentModel);
  }

  @override
  Future deleteMoment(String momentId) async {
    return await momentsDBRef.doc(momentId).delete();
  }

  @override
  Future<List<MomentModel>> fetchAllMomentsByMonthAndYear(
    String year,
    String month,
    String timelineId,
  ) async {
    final result =
        await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

    return result.docs
        .map((e) => e.data())
        .toList()
        .where((element) => element.month == month && element.year == year)
        .toList();
  }

  @override
  Future<List<MomentModel>> fetchAllMomentsByYear({
    required String year,
    required String timelineId,
  }) async {
    final result =
        await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

    return result.docs.map((e) => e.data()).where((element) => element.year == year).toList();
  }

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
  }) async {
    final result =
        await momentsDBRef.where('time_line_id', isEqualTo: timelineId).get(const GetOptions(source: Source.server));

    return result.docs
        .map((e) => e.data())
        .where((e) =>
            e.dateTime.isBefore(endDate) && e.dateTime.isAfter(startDate))
        .toList();
  }
}
