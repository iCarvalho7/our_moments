import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

class UpdateRelationshipEndDateParams {
  final TimeLine timeline;
  final DateTime? date;
  final bool enforceEndDate;

  const UpdateRelationshipEndDateParams({
    required this.timeline,
    this.date,
    this.enforceEndDate = true,
  });
}

@injectable
class UpdateRelationshipEndDateUseCase
    extends AsyncUseCase<TimeLine, UpdateRelationshipEndDateParams> {
  final TimeLineRepository repository;

  const UpdateRelationshipEndDateUseCase(this.repository);

  @override
  Future<TimeLine> execute(UpdateRelationshipEndDateParams params) =>
      repository.updateRelationshipEndDate(params.timeline, params.date,
          enforceEndDate: params.enforceEndDate);
}
