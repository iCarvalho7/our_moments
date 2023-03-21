import '../models/moment_model.dart';

abstract class MomentsDataSource {
  Future deleteMoment(String momentId);

  Future updateMoment(String momentId, Map<String, dynamic> momentModel);

  Future registerMoment({required MomentModel moment});

  Future<MomentModel> fetchMoment({required String momentId});

  Future<List<MomentModel>> fetchAllMomentsByMonthAndYear({
    required String year,
    required String month,
  });

  Future<List<MomentModel>> fetchAllMomentsByYear({
    required String year,
  });
}
