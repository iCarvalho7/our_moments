import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';

import 'delete_authored_moments_in_timeline_use_case.dart';

class LeaveTimelineParams {
  final TimeLine timeLine;
  final String userEmail;

  /// When true, the moments authored by the user are permanently deleted
  /// (LGPD "delete my data"). Otherwise they stay for the remaining members.
  final bool deleteAuthoredMoments;

  const LeaveTimelineParams({
    required this.timeLine,
    required this.userEmail,
    this.deleteAuthoredMoments = false,
  });
}

/// Removes the current user from a shared timeline. Optionally deletes the
/// moments they authored first (LGPD compliance).
@injectable
class LeaveTimelineUseCase extends AsyncUseCase<void, LeaveTimelineParams> {
  final TimeLineRepository _timeLineRepository;
  final DeleteAuthoredMomentsInTimelineUseCase _deleteAuthoredMomentsUseCase;

  LeaveTimelineUseCase(
    this._timeLineRepository,
    this._deleteAuthoredMomentsUseCase,
  );

  @override
  Future<void> execute(LeaveTimelineParams params) async {
    if (params.deleteAuthoredMoments) {
      await _deleteAuthoredMomentsUseCase.execute(
        DeleteAuthoredMomentsInTimelineParams(
          timelineId: params.timeLine.id,
          authorEmail: params.userEmail,
        ),
      );
    }
    await _timeLineRepository.removeTimeLineMember(
      params.timeLine,
      params.userEmail,
    );
  }
}
