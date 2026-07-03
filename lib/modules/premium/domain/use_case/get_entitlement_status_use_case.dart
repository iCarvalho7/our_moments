import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/entitlement_status.dart';
import '../repository/purchase_repository.dart';

/// Reads the current entitlement status from the store (no purchase flow).
/// Used by the global listener / [EntitlementSyncService] to keep Firestore and
/// the gates in sync.
@injectable
class GetEntitlementStatusUseCase
    extends AsyncUseCase<EntitlementStatus, NoParams> {
  final PurchaseRepository repository;

  const GetEntitlementStatusUseCase(this.repository);

  @override
  Future<EntitlementStatus> execute(NoParams params) =>
      repository.entitlementStatus();
}
