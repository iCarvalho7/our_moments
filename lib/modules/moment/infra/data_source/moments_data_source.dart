import '../models/moment_model.dart';

abstract class MomentsDataSource {
  Future registerMoment({required MomentModel moment});

  Future<MomentModel> fetchMoment({required String momentId});
}
