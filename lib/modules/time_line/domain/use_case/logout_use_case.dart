import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

@injectable
class LogoutUseCase extends AsyncUseCase<void, NoParams> {

  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<void> execute(NoParams params) {
    return _authRepository.logout();
  }
}