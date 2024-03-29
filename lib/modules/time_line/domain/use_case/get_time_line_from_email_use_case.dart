import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';

import '../repository/time_line_repository.dart';

@injectable
class GetTimeLineFromEmailUseCase extends AsyncUseCase<List<TimeLine>, NoParams> {

  final AuthRepository authRepository;
  final TimeLineRepository _timeLineRepository;

  GetTimeLineFromEmailUseCase(this.authRepository, this._timeLineRepository);

  @override
  Future<List<TimeLine>> execute(NoParams params) async {
    final user = authRepository.getCurrentUser();

    if (user == null || user.email == null) {
      return [];
    }

    final timeLines = await _timeLineRepository.getTimelinesIdByEmail(user.email!);
    return timeLines;
  }
}
