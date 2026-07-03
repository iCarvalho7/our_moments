import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../repository/purchase_repository.dart';

/// Opens the RevenueCat-hosted Customer Center (manage subscription, restore,
/// cancel, request a refund).
@injectable
class PresentCustomerCenterUseCase extends AsyncUseCase<void, NoParams> {
  final PurchaseRepository repository;

  const PresentCustomerCenterUseCase(this.repository);

  @override
  Future<void> execute(NoParams params) => repository.presentCustomerCenter();
}
