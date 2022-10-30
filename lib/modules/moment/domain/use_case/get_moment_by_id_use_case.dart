import 'dart:async';

import 'package:injectable/injectable.dart';

import '../entities/moment.dart';
import '../repository/moment_repository.dart';

@injectable
class GetMomentByIdUseCase {
  final MomentRepository repository;

  GetMomentByIdUseCase(this.repository);

  FutureOr<Moment> call(String momentId) async {
    final moment = await repository.fetchMomentById(momentId);
    return moment;
  }
}
