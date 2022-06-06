import 'package:nossos_momentos/modules/add_moment/infra/models/moment_model.dart';

abstract class MomentsDataSource {
  Future registerMoment({required MomentModel moment});
}