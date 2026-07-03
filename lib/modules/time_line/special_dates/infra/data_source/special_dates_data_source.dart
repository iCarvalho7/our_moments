import '../model/special_date_model.dart';

abstract class SpecialDatesDataSource {
  Stream<List<SpecialDateModel>> watch(String timelineId);

  /// Adds a special date and returns the generated Firestore document id.
  Future<String> add(String timelineId, SpecialDateModel date);

  Future<void> remove(String timelineId, String id);
}
