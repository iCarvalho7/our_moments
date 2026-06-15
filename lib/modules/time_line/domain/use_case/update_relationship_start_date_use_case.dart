import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

class UpdateRelationshipStartDateParams {
  final TimeLine timeline;
  final DateTime date;

  const UpdateRelationshipStartDateParams({
    required this.timeline,
    required this.date,
  });
}

@injectable
class UpdateRelationshipStartDateUseCase
    extends AsyncUseCase<TimeLine, UpdateRelationshipStartDateParams> {
  final TimeLineRepository repository;

  const UpdateRelationshipStartDateUseCase(this.repository);

  @override
  Future<TimeLine> execute(UpdateRelationshipStartDateParams params) =>
      repository.updateRelationshipStartDate(params.timeline, params.date);
}
