import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../../../time_line/domain/entity/time_line.dart';
import '../../../time_line/domain/repository/time_line_repository.dart';
import '../entity/entitlement_status.dart';

class SyncEntitlementParams {
  final TimeLine timeline;
  final EntitlementStatus status;

  const SyncEntitlementParams({
    required this.timeline,
    required this.status,
  });
}

/// Mirrors the RevenueCat entitlement onto the shared timeline doc so the
/// partner who did not buy (and offline reads) also unlock premium.
///
/// `entitlement active` → `time_line/{id}.is_premium = true` (+ `premium_until`
/// when the entitlement has an expiry; null = lifetime).
@injectable
class SyncEntitlementUseCase extends AsyncUseCase<TimeLine, SyncEntitlementParams> {
  final TimeLineRepository repository;

  const SyncEntitlementUseCase(this.repository);

  @override
  Future<TimeLine> execute(SyncEntitlementParams params) =>
      repository.updateTimeLinePremium(
        params.timeline,
        isPremium: params.status.isActive,
        premiumUntil: params.status.expirationDate,
      );
}
