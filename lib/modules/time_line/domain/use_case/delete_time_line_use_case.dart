import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

@injectable
class DeleteTimeLineUseCase extends AsyncUseCase<void, String> {
  final TimeLineRepository _timeLineRepository;

  DeleteTimeLineUseCase(this._timeLineRepository);

  @override
  Future<void> execute(String timelineId) {
    return _timeLineRepository.deleteTimeLine(timelineId);
  }
}
