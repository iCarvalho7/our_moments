import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/timeline_permissions.dart';
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
    // Block the last remaining owner from abandoning a shared timeline, which
    // would leave the other members without anyone able to manage it.
    final isOwner = TimelinePermissions.isOwner(params.timeLine, params.userEmail);
    final hasOtherOwners = TimelinePermissions.ownerEmails(params.timeLine)
        .any((e) => e != params.userEmail);
    final hasOtherMembers = params.timeLine.emails.length > 1;

    if (isOwner && !hasOtherOwners && hasOtherMembers) {
      throw Exception(
        'Você é o único dono desta história. Promova outro membro a dono antes de sair.',
      );
    }

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
