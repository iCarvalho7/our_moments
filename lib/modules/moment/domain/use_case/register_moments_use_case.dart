import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../entities/moment.dart';
import '../repository/moment_repository.dart';

@injectable
class RegisterMomentsUseCase extends AsyncUseCase<void, Moment> {
  final MomentRepository repository;

  RegisterMomentsUseCase(this.repository);

  @override
  Future<void> execute(Moment params) => repository.registerMoment(moment: params);
}
