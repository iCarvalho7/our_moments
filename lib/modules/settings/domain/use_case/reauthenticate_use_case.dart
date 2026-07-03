import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

/// Re-authenticates the current user with their password. Needed before
/// account deletion when Firebase rejects it with `requires-recent-login`.
@injectable
class ReauthenticateUseCase extends AsyncUseCase<void, String> {
  ReauthenticateUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> execute(String password) {
    return _authRepository.reauthenticateWithPassword(password);
  }
}
