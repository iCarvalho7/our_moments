import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/moment/domain/repository/moment_repository.dart';

abstract class DeleteMomentsUseCase {
  Future<void> call(String momentId);
}

@Injectable(as: DeleteMomentsUseCase)
class DeleteMomentsUseCaseImpl extends DeleteMomentsUseCase{
  DeleteMomentsUseCaseImpl(this._repository);

  final MomentRepository _repository;

  @override
  Future<void> call(String momentId) async {
    return _repository.deleteMoment(momentId);
  }
}
