import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/login/domain/use_case/sign_in_use_case.dart';

@injectable
class SignUpUseCase extends AsyncUseCase<void, SignInParam> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<void> execute(SignInParam params) =>
      _authRepository.signUp(params.username, params.password);
}
