import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../../../login/domain/repository/auth_repository.dart';
import '../../../user/domain/entity/user_premium.dart';
import '../../../user/domain/repository/user_premium_repository.dart';
import '../entity/entitlement_status.dart';

class SyncUserEntitlementParams {
  final EntitlementStatus status;

  const SyncUserEntitlementParams({required this.status});
}

/// Mirrors the RevenueCat entitlement onto the per-user doc (`users/{uid}`) so
/// the individual plan unlocks the individual-tier features for that user.
///
/// `entitlement active` → `users/{uid}.is_premium = true` (+ `premium_until`
/// when the entitlement has an expiry; null = lifetime). The couple plan is
/// handled separately by [SyncEntitlementUseCase] on the timeline doc.
@injectable
class SyncUserEntitlementUseCase
    extends AsyncUseCase<UserPremium, SyncUserEntitlementParams> {
  final UserPremiumRepository _repository;
  final AuthRepository _authRepository;

  const SyncUserEntitlementUseCase(this._repository, this._authRepository);

  @override
  Future<UserPremium> execute(SyncUserEntitlementParams params) async {
    final user = _authRepository.getCurrentUser();
    final uid = user?.uid;
    if (uid == null) {
      throw StateError('No authenticated user to sync the individual plan.');
    }

    return _repository.updatePremium(
      uid,
      email: user?.email ?? '',
      isPremium: params.status.isActive,
      premiumUntil: params.status.expirationDate,
    );
  }
}
