import 'package:injectable/injectable.dart';

import '../../../core/premium/premium_feature.dart';
import '../../domain/entity/entitlement_status.dart';
import '../../domain/entity/premium_plan.dart';
import '../../domain/repository/purchase_repository.dart';
import '../data_source/purchase_data_source.dart';

@Injectable(as: PurchaseRepository)
class PurchaseRepositoryImpl extends PurchaseRepository {
  final PurchaseDataSource dataSource;

  PurchaseRepositoryImpl(this.dataSource);

  @override
  Future<List<PremiumPlan>> offerings() => dataSource.getOfferings();

  @override
  Future<EntitlementStatus> purchase(PremiumPlan plan) =>
      dataSource.purchase(plan);

  @override
  Future<EntitlementStatus> restore() => dataSource.restore();

  @override
  Future<EntitlementStatus> entitlementStatus() =>
      dataSource.entitlementStatus();

  @override
  Future<EntitlementStatus> presentPaywall(PremiumTier tier) =>
      dataSource.presentPaywall(tier);

  @override
  Future<void> presentCustomerCenter() => dataSource.presentCustomerCenter();

  @override
  bool get isStoreAvailable => dataSource.isStoreAvailable;
}
