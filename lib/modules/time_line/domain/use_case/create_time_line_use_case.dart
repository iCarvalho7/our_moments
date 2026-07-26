import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

import '../../../login/domain/repository/auth_repository.dart';
import '../entity/time_line.dart';

/// Parameters for creating a timeline. [momentEditPolicy] controls whether
/// editors may edit each other's moments ('collaborative') or only their own
/// ('individual', the default).
class CreateTimeLineParams {
  final String momentEditPolicy;

  const CreateTimeLineParams({this.momentEditPolicy = 'individual'});
}

@injectable
class CreateTimeLineUseCase
    extends AsyncUseCase<TimeLine, CreateTimeLineParams> {
  final TimeLineRepository _timeLineRepository;
  final AuthRepository _authRepository;

  CreateTimeLineUseCase(this._timeLineRepository, this._authRepository);

  @override
  Future<TimeLine> execute(CreateTimeLineParams params) async {
    final user = _authRepository.getCurrentUser();

    if (user != null && user.email != null) {
      final timeLineId = _timeLineRepository.generateTimeLineId();
      final email = user.email!;

      final timeLine = TimeLine(
        id: timeLineId,
        owners: [email],
        roles: {email: 'owner'},
        momentEditPolicy: params.momentEditPolicy,
        createdDate: Timestamp.now(),
        emails: [email],
        momentIds: [],
        name: _defaultName(user),
      );

      return await _timeLineRepository.createTimeLine(timeLine);
    } else {
      throw Exception('User is not Authenticated');
    }
  }

  String _defaultName(User user) {
    final display = user.displayName;
    if (display != null && display.trim().isNotEmpty) {
      final firstName = display.trim().split(' ').first;
      return 'História de $firstName';
    }
    final localPart = (user.email ?? '').split('@').first;
    if (localPart.isEmpty) return 'Minha história';
    final capitalized = localPart[0].toUpperCase() + localPart.substring(1);
    return 'História de $capitalized';
  }
}
