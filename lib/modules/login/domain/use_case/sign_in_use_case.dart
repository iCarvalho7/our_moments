import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

class SignInParam {
  final String username;
  final String password;

  SignInParam(this.username, this.password);
}

@injectable
class SignInUseCase extends AsyncUseCase<void, SignInParam> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<void> execute(SignInParam params) {
    return _authRepository.signIn(params.username, params.password);
  }
}
