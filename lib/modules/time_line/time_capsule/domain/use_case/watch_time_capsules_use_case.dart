import 'package:injectable/injectable.dart';

import '../entity/time_capsule.dart';
import '../repository/time_capsule_repository.dart';

@injectable
class WatchTimeCapsulesUseCase {
  final TimeCapsuleRepository _repository;

  WatchTimeCapsulesUseCase(this._repository);

  Stream<List<TimeCapsule>> call(String timelineId) {
    return _repository.watch(timelineId);
  }
}
