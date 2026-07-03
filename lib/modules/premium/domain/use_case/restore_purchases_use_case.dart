import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/entitlement_status.dart';
import '../repository/purchase_repository.dart';

@injectable
class RestorePurchasesUseCase
    extends AsyncUseCase<EntitlementStatus, NoParams> {
  final PurchaseRepository repository;

  const RestorePurchasesUseCase(this.repository);

  @override
  Future<EntitlementStatus> execute(NoParams params) => repository.restore();
}
