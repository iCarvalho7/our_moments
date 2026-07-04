import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

/// Cancels a pending multi-owner deletion by clearing the consensus map.
/// Returns the updated timeline.
@injectable
class RejectTimelineDeletionUseCase extends AsyncUseCase<TimeLine, TimeLine> {
  final TimeLineRepository _repository;

  RejectTimelineDeletionUseCase(this._repository);

  @override
  Future<TimeLine> execute(TimeLine timeline) {
    return _repository.updatePendingDeletion(timeline, null);
  }
}
