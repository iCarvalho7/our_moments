import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';

abstract class RegisterMomentRepository {
  Future registerMoment({required Moment moment});
}
