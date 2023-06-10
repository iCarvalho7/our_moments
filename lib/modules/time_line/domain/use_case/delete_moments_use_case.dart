import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/repository/moment_repository.dart';

@injectable
class DeleteMomentsUseCase extends AsyncUseCase<void, String> {
  DeleteMomentsUseCase(this._repository);

  final MomentRepository _repository;

  @override
  Future<void> execute(String params) => _repository.deleteMoment(params);

}
