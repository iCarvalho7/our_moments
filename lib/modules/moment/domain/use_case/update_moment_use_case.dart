import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import '../entities/moment.dart';

import '../repository/moment_repository.dart';

@injectable
class UpdateMomentUseCase extends AsyncUseCase<void, Moment>{
  final MomentRepository _repository;

  UpdateMomentUseCase(this._repository);

  @override
  Future<void> execute(Moment params) => _repository.editMoment(params);
}