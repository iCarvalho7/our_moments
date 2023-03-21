import 'package:injectable/injectable.dart';
import '../entities/moment.dart';

import '../repository/moment_repository.dart';

@injectable
class UpdateMomentUseCase {
  final MomentRepository _repository;

  UpdateMomentUseCase(this._repository);

  Future call(Moment moment) async {
    final response = await _repository.editMoment(moment);
    return response;
  }
}