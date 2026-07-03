import 'package:injectable/injectable.dart';

import '../../../core/use_case/use_case.dart';
import '../entity/time_line.dart';
import '../repository/time_line_repository.dart';

class UpdateRolesParams {
  final TimeLine timeline;
  final Map<String, String> roles;

  const UpdateRolesParams({
    required this.timeline,
    required this.roles,
  });
}

@injectable
class UpdateRolesUseCase extends AsyncUseCase<TimeLine, UpdateRolesParams> {
  final TimeLineRepository repository;

  const UpdateRolesUseCase(this.repository);

  @override
  Future<TimeLine> execute(UpdateRolesParams params) =>
      repository.updateRoles(params.timeline, params.roles);
}
