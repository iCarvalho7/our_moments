import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

class UpdateTimeLineDetailsParams {
  final TimeLine timeline;
  final String name;
  final int? accentColor;

  const UpdateTimeLineDetailsParams({
    required this.timeline,
    required this.name,
    this.accentColor,
  });
}

@injectable
class UpdateTimeLineDetailsUseCase
    extends AsyncUseCase<TimeLine, UpdateTimeLineDetailsParams> {
  final TimeLineRepository repository;

  const UpdateTimeLineDetailsUseCase(this.repository);

  @override
  Future<TimeLine> execute(UpdateTimeLineDetailsParams params) =>
      repository.updateTimeLineDetails(
        params.timeline,
        name: params.name,
        accentColor: params.accentColor,
      );
}
