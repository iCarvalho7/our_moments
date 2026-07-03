import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/repository/moment_repository.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class DeleteTimeLineUseCase extends AsyncUseCase<void, String> {
  final TimeLineRepository _timeLineRepository;
  final MomentRepository _momentRepository;

  DeleteTimeLineUseCase(this._timeLineRepository, this._momentRepository);

  @override
  Future<void> execute(String timelineId) async {
    // Delete the moments first so they don't stay orphaned in Firestore when
    // the timeline doc is removed.
    await _momentRepository.deleteMomentsByTimeline(timelineId);
    await _timeLineRepository.deleteTimeLine(timelineId);
  }
}
