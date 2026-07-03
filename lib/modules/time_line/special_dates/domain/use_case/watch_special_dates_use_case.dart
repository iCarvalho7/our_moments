import 'package:injectable/injectable.dart';

import '../entity/special_date.dart';
import '../repository/special_dates_repository.dart';

@injectable
class WatchSpecialDatesUseCase {
  final SpecialDatesRepository _repository;

  WatchSpecialDatesUseCase(this._repository);

  Stream<List<SpecialDate>> call(String timelineId) {
    return _repository.watch(timelineId);
  }
}
