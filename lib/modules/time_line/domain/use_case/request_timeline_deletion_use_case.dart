import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../entity/time_line.dart';
import '../entity/timeline_permissions.dart';
import '../repository/time_line_repository.dart';
import 'delete_time_line_use_case.dart';

class RequestTimelineDeletionParams {
  final TimeLine timeline;
  final String userEmail;

  const RequestTimelineDeletionParams({
    required this.timeline,
    required this.userEmail,
  });
}

/// Starts a timeline deletion. When the timeline has more than one owner the
/// deletion needs consensus, so it just records the requester's approval in
/// `pendingDeletion`. With a single owner it deletes right away.
///
/// Returns the updated timeline while consensus is pending, or null once the
/// timeline has actually been deleted.
@injectable
class RequestTimelineDeletionUseCase
    extends AsyncUseCase<TimeLine?, RequestTimelineDeletionParams> {
  final TimeLineRepository _repository;
  final DeleteTimeLineUseCase _deleteTimeLineUseCase;

  RequestTimelineDeletionUseCase(this._repository, this._deleteTimeLineUseCase);

  @override
  Future<TimeLine?> execute(RequestTimelineDeletionParams params) async {
    // A deletion is already awaiting consensus: don't overwrite the existing
    // approvals with a fresh `{requester: true}` map. Keep the current state.
    if (TimelinePermissions.isDeletionPending(params.timeline)) {
      return params.timeline;
    }

    final owners = _ownersOf(params.timeline);
    if (owners.length > 1) {
      return _repository.updatePendingDeletion(
        params.timeline,
        {params.userEmail: true},
      );
    }
    await _deleteTimeLineUseCase.execute(params.timeline.id);
    return null;
  }

  List<String> _ownersOf(TimeLine tl) {
    final fromRoles = TimelinePermissions.ownerEmails(tl);
    return fromRoles.isNotEmpty ? fromRoles : tl.owners;
  }
}
