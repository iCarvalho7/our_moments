import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/premium_plan.dart';
import '../repository/purchase_repository.dart';

@injectable
class GetOfferingsUseCase extends AsyncUseCase<List<PremiumPlan>, NoParams> {
  final PurchaseRepository repository;

  const GetOfferingsUseCase(this.repository);

  @override
  Future<List<PremiumPlan>> execute(NoParams params) => repository.offerings();
}
