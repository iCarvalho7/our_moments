import '../entity/special_date.dart';

abstract class SpecialDatesRepository {
  Stream<List<SpecialDate>> watch(String timelineId);

  /// Adds a special date and returns the generated Firestore document id.
  Future<String> add(String timelineId, SpecialDate date);

  Future<void> remove(String timelineId, String id);
}
