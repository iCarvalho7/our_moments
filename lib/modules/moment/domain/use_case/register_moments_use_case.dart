import 'dart:async';

import 'package:injectable/injectable.dart';

import '../entities/moment.dart';
import '../repository/moment_repository.dart';

@injectable
class RegisterMomentsUseCase {
  final MomentRepository repository;

  RegisterMomentsUseCase(this.repository);

  FutureOr<void> call(Moment moment) =>
      repository.registerMoment(moment: moment);
}
