import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/moment/domain/repository/moment_repository.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/leave_timeline_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/timeline_permissions.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';
import 'package:nossos_momentos/modules/user/domain/repository/user_premium_repository.dart';

/// Permanently deletes the current user's account and their data.
///
/// Steps (all idempotent, so the whole use case can be safely re-run after a
/// `requires-recent-login` reauthentication):
/// 1. For every timeline the user belongs to:
///    - sole member -> delete the timeline doc and all its moments;
///    - shared      -> if the user is the only owner, hand ownership to another
///      member first, then leave and delete the moments the user authored
///      (LGPD obligation).
/// 2. Delete the per-user premium doc `users/{uid}`.
/// 3. Delete the Firebase Auth account (must be last — while still signed in).
///
/// The auth deletion may throw a [FirebaseAuthException] with code
/// `requires-recent-login`; the caller reauthenticates and calls this again.
@injectable
class DeleteAccountUseCase extends AsyncUseCase<void, NoParams> {
  DeleteAccountUseCase(
    this._authRepository,
    this._timeLineRepository,
    this._momentRepository,
    this._userPremiumRepository,
    this._leaveTimelineUseCase,
  );

  final AuthRepository _authRepository;
  final TimeLineRepository _timeLineRepository;
  final MomentRepository _momentRepository;
  final UserPremiumRepository _userPremiumRepository;
  final LeaveTimelineUseCase _leaveTimelineUseCase;

  @override
  Future<void> execute(NoParams params) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) return;

    final email = user.email;
    if (email != null) {
      final timelines = await _timeLineRepository.getTimelinesIdByEmail(email);
      for (final timeline in timelines) {
        if (timeline.emails.length <= 1) {
          await _momentRepository.deleteMomentsByTimeline(timeline.id);
          await _timeLineRepository.deleteTimeLine(timeline.id);
          continue;
        }

        // Shared timeline: keep an owner behind before leaving.
        var tl = timeline;
        final owners = TimelinePermissions.ownerEmails(timeline).isNotEmpty
            ? TimelinePermissions.ownerEmails(timeline)
            : timeline.owners;
        final isSoleOwner = owners.length == 1 && owners.first == email;
        if (isSoleOwner) {
          final heir = timeline.emails.firstWhere(
            (e) => e != email,
            orElse: () => '',
          );
          if (heir.isNotEmpty) {
            final roles = Map<String, String>.from(timeline.roles);
            roles[heir] = 'owner';
            tl = await _timeLineRepository.updateRoles(timeline, roles);
          }
        }

        // LGPD: deleting the account deletes the user's authored moments too.
        await _leaveTimelineUseCase.execute(LeaveTimelineParams(
          timeLine: tl,
          userEmail: email,
          deleteAuthoredMoments: true,
        ));
      }
    }

    await _userPremiumRepository.delete(user.uid);

    // Kept last: this ends the session and may require a recent login.
    await _authRepository.deleteAccount();
  }
}
