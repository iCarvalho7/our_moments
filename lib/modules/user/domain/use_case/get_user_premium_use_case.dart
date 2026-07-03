import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';

import '../entity/user_premium.dart';
import '../repository/user_premium_repository.dart';

/// Loads the per-user premium entitlement for the currently authenticated user.
///
/// Returns null when there is no logged-in user or no `users/{uid}` doc — both
/// mean "no individual premium" (the timeline/couple entitlement is unaffected).
@injectable
class GetUserPremiumUseCase extends AsyncUseCase<UserPremium?, NoParams> {
  final UserPremiumRepository _repository;
  final AuthRepository _authRepository;

  GetUserPremiumUseCase(this._repository, this._authRepository);

  @override
  Future<UserPremium?> execute(NoParams params) async {
    final uid = _authRepository.getCurrentUser()?.uid;

    if (uid == null) return null;

    return _repository.getByUid(uid);
  }
}
