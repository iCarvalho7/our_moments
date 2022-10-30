import 'dart:async';

import '../entities/moment.dart';

abstract class MomentRepository {
  Future registerMoment({required Moment moment});
  Future editMoment(Moment moment);
  FutureOr<Moment> fetchMomentById(String id);
}
