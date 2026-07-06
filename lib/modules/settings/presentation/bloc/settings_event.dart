part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class FetchEmailEvent extends SettingsEvent {
  /// Pass a non-null [timeLineId] to load the full timeline settings.
  /// Pass null to load account-only settings (email + delete account).
  final String? timeLineId;

  FetchEmailEvent({this.timeLineId});
}

class DeleteEmailEvent extends SettingsEvent {
  final String email;

  DeleteEmailEvent({required this.email});
}

class AddEmailEvent extends SettingsEvent {
  final String email;

  AddEmailEvent({required this.email});
}

class UpdateTimeLineDetailsEvent extends SettingsEvent {
  final String name;
  final int? accentColor;

  UpdateTimeLineDetailsEvent({required this.name, this.accentColor});
}

class UpdateCoupleHeaderEvent extends SettingsEvent {
  final Map<String, String> nicknames;

  /// A freshly picked local cover (file path on mobile, data URL on web).
  final String? localCoverPath;

  /// The existing remote cover URL to keep when no new photo was picked.
  final String keepCoverUrl;

  UpdateCoupleHeaderEvent({
    required this.nicknames,
    this.localCoverPath,
    this.keepCoverUrl = '',
  });
}

class UpdateRelationshipEndDateEvent extends SettingsEvent {
  final DateTime? date;
  final bool enforceEndDate;

  UpdateRelationshipEndDateEvent({this.date, this.enforceEndDate = true});
}

class UpdateAccessLevelEvent extends SettingsEvent {
  final String email;

  /// 'editor' or 'viewer'
  final String level;

  UpdateAccessLevelEvent({required this.email, required this.level});
}

class DeleteTimeLineEvent extends SettingsEvent {}

/// Requests deletion of the current timeline. Deletes immediately with a single
/// owner, or starts a multi-owner consensus otherwise.
class RequestTimelineDeletionEvent extends SettingsEvent {}

/// The current owner approves a pending multi-owner deletion.
class ApproveTimelineDeletionEvent extends SettingsEvent {}

/// Cancels a pending multi-owner deletion.
class RejectTimelineDeletionEvent extends SettingsEvent {}

/// Removes the current user from the shared timeline. When
/// [deleteAuthoredMoments] is true, the moments they authored are deleted too
/// (LGPD).
class LeaveTimelineEvent extends SettingsEvent {
  final bool deleteAuthoredMoments;

  LeaveTimelineEvent({this.deleteAuthoredMoments = false});
}

/// Deletes the current user's account and their data.
class DeleteAccountEvent extends SettingsEvent {}

/// Re-authenticates with [password] and, on success, retries the account
/// deletion. Dispatched after a `requires-recent-login` error.
class ReauthenticateAndDeleteAccountEvent extends SettingsEvent {
  final String password;

  ReauthenticateAndDeleteAccountEvent({required this.password});
}
