import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/edit_moment/domain/repository/edit_moment_repository.dart';

@injectable
class UpdateMomentUseCase {
  final EditMomentRepository _repository;

  UpdateMomentUseCase(this._repository);

  Future call(Moment moment) async {
    final response = await _repository.editMoment(moment);
    return response;
  }
}