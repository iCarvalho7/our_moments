import 'package:injectable/injectable.dart';
import '../entities/moment.dart';

import '../repository/moment_repository.dart';

@injectable
class UpdateMomentUseCase {
  final MomentRepository _repository;

  UpdateMomentUseCase(this._repository);

  Future call(Moment moment) => _repository.editMoment(moment);
}