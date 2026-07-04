import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../entity/time_line.dart';
import '../entity/timeline_permissions.dart';
import '../repository/time_line_repository.dart';
import 'delete_time_line_use_case.dart';

class ApproveTimelineDeletionParams {
  final TimeLine timeline;
  final String userEmail;

  const ApproveTimelineDeletionParams({
    required this.timeline,
    required this.userEmail,
  });
}

/// Records an owner's approval of a pending deletion. When every owner has
/// approved, the timeline is deleted.
///
/// Returns the updated timeline while consensus is still pending, or null once
/// the timeline has actually been deleted.
@injectable
class ApproveTimelineDeletionUseCase
    extends AsyncUseCase<TimeLine?, ApproveTimelineDeletionParams> {
  final TimeLineRepository _repository;
  final DeleteTimeLineUseCase _deleteTimeLineUseCase;

  ApproveTimelineDeletionUseCase(this._repository, this._deleteTimeLineUseCase);

  @override
  Future<TimeLine?> execute(ApproveTimelineDeletionParams params) async {
    final pending = Map<String, bool>.from(params.timeline.pendingDeletion ?? {});
    pending[params.userEmail] = true;

    final owners = _ownersOf(params.timeline);
    final everyoneApproved =
        owners.isNotEmpty && owners.every((o) => pending[o] == true);

    if (everyoneApproved) {
      await _deleteTimeLineUseCase.execute(params.timeline.id);
      return null;
    }
    return _repository.updatePendingDeletion(params.timeline, pending);
  }

  List<String> _ownersOf(TimeLine tl) {
    final fromRoles = TimelinePermissions.ownerEmails(tl);
    return fromRoles.isNotEmpty ? fromRoles : tl.owners;
  }
}
