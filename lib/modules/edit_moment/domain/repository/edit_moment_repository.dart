import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';

abstract class EditMomentRepository {
  Future editMoment(Moment moment);
}