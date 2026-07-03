import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/logging/request_logger.dart';
import '../../../bucket_list/external/firebase/firebase_bucket_list_data_source.dart';
import '../../infra/data_source/special_dates_data_source.dart';
import '../../infra/model/special_date_model.dart';

@Injectable(as: SpecialDatesDataSource)
class FirebaseSpecialDatesDataSource extends SpecialDatesDataSource {
  final CollectionReference<Map<String, dynamic>> timeLineRef;

  FirebaseSpecialDatesDataSource(
    @Named(FirebaseBucketListDataSource.timeLineRawCollectionParam)
    this.timeLineRef,
  );

  static const String specialDatesCollection = 'special_dates';

  CollectionReference<Map<String, dynamic>> _datesRef(String timelineId) =>
      timeLineRef.doc(timelineId).collection(specialDatesCollection);

  @override
  Stream<List<SpecialDateModel>> watch(String timelineId) {
    return _datesRef(timelineId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SpecialDateModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<String> add(String timelineId, SpecialDateModel date) =>
      RequestLogger.track(
        'SpecialDates.add',
        params: {'timelineId': timelineId, 'title': date.title},
        request: () async {
          final ref = await _datesRef(timelineId).add(date.toJson());
          return ref.id;
        },
      );

  @override
  Future<void> remove(String timelineId, String id) => RequestLogger.track(
        'SpecialDates.remove',
        params: {'timelineId': timelineId, 'id': id},
        request: () => _datesRef(timelineId).doc(id).delete(),
      );
}
