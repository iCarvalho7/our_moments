import 'package:injectable/injectable.dart';

import '../../../core/premium/premium_feature.dart';
import '../../../core/use_case/use_case.dart';
import '../entity/entitlement_status.dart';
import '../repository/purchase_repository.dart';

/// Opens the RevenueCat-hosted paywall for the given [PremiumTier]'s offering
/// and returns the real entitlement status after it closes.
@injectable
class PresentPaywallUseCase
    extends AsyncUseCase<EntitlementStatus, PremiumTier> {
  final PurchaseRepository repository;

  const PresentPaywallUseCase(this.repository);

  @override
  Future<EntitlementStatus> execute(PremiumTier tier) =>
      repository.presentPaywall(tier);
}
