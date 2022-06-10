import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/repository/get_moment_repository.dart';

@injectable
class GetMomentByIdUseCase {

  final GetMomentRepository repository;

  GetMomentByIdUseCase(this.repository);

  FutureOr<Moment> call(String momentId) async {
    final moment = await repository.fetchMomentById(momentId);
    return moment;
  }
}