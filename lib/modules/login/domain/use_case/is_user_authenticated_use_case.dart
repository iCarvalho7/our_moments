import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

@injectable
class IsUserAuthenticatedUseCase extends UseCase<bool, NoParams> {
  final AuthRepository _authRepository;

  IsUserAuthenticatedUseCase(this._authRepository);

  @override
  bool execute(NoParams params) {
    return _authRepository.isUserAuthenticated();
  }
}
