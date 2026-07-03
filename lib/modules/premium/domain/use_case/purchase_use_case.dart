import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/entitlement_status.dart';
import '../entity/premium_plan.dart';
import '../repository/purchase_repository.dart';

@injectable
class PurchaseUseCase extends AsyncUseCase<EntitlementStatus, PremiumPlan> {
  final PurchaseRepository repository;

  const PurchaseUseCase(this.repository);

  @override
  Future<EntitlementStatus> execute(PremiumPlan params) =>
      repository.purchase(params);
}
