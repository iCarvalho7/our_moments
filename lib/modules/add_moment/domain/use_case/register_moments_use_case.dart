import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/repository/register_moment_repository.dart';

@injectable
class RegisterMomentsUseCase {
  final RegisterMomentRepository repository;

  RegisterMomentsUseCase(this.repository);

  FutureOr<void> call(Moment moment) =>
      repository.registerMoment(moment: moment);
}
