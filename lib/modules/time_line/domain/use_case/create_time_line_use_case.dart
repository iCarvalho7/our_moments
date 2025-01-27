import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

import '../../../login/domain/repository/auth_repository.dart';
import '../entity/time_line.dart';

@injectable
class CreateTimeLineUseCase extends AsyncUseCase<TimeLine, NoParams> {
  final TimeLineRepository _timeLineRepository;
  final AuthRepository _authRepository;

  CreateTimeLineUseCase(this._timeLineRepository, this._authRepository);

  @override
  Future<TimeLine> execute(NoParams params) async {
    final user = _authRepository.getCurrentUser();

    if (user != null && user.email != null) {
      final timeLineId = _timeLineRepository.generateTimeLineId();

      final timeLine = TimeLine(
        id: timeLineId,
        createdDate: Timestamp.now(),
        emails: [user.email!],
        momentIds: [],
      );

      return await _timeLineRepository.createTimeLine(timeLine);
    } else {
      throw Exception('User is not Authenticated');
    }
  }
}
