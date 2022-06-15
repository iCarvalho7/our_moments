import 'dart:async';

import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';

abstract class GetMomentRepository {
  FutureOr<Moment> fetchMomentById(String id);
}
