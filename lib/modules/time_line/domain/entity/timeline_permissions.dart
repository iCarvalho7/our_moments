import '../../../moment/domain/entities/moment.dart';
import 'time_line.dart';

enum TimelineRole { owner, editor, viewer }

/// Central authority for "who can do what" on a timeline. Roles live on the
/// [TimeLine] doc (`roles` map, email → 'owner' | 'editor' | 'viewer'); anyone
/// not listed defaults to editor.
class TimelinePermissions {
  const TimelinePermissions._();

  static TimelineRole roleOf(TimeLine tl, String email) {
    final r = tl.roles[email];
    if (r == 'owner') return TimelineRole.owner;
    if (r == 'viewer') return TimelineRole.viewer;
    return TimelineRole.editor; // default
  }

  static bool isOwner(TimeLine tl, String email) =>
      roleOf(tl, email) == TimelineRole.owner;

  static bool canEdit(TimeLine tl, String email) =>
      roleOf(tl, email) != TimelineRole.viewer;

  static bool canManageMembers(TimeLine tl, String email) => isOwner(tl, email);

  static bool canDeleteTimeline(TimeLine tl, String email) => isOwner(tl, email);

  static bool canEditMoment(TimeLine tl, Moment m, String email) {
    if (isOwner(tl, email)) return true;
    if (roleOf(tl, email) == TimelineRole.viewer) return false;
    if (tl.momentEditPolicy == 'collaborative') return true;
    return m.author == email; // individual
  }

  static bool canDeleteMoment(TimeLine tl, Moment m, String email) =>
      canEditMoment(tl, m, email);

  static bool isDeletionPending(TimeLine tl) =>
      tl.pendingDeletion != null && tl.pendingDeletion!.isNotEmpty;

  /// Emails of all members whose role is 'owner'.
  static List<String> ownerEmails(TimeLine tl) => tl.roles.entries
      .where((e) => e.value == 'owner')
      .map((e) => e.key)
      .toList();
}
