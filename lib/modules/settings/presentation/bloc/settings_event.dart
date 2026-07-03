part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class FetchEmailEvent extends SettingsEvent {
  final String timeLineId;

  FetchEmailEvent({required this.timeLineId});
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

/// Deletes the current user's account and their data.
class DeleteAccountEvent extends SettingsEvent {}

/// Re-authenticates with [password] and, on success, retries the account
/// deletion. Dispatched after a `requires-recent-login` error.
class ReauthenticateAndDeleteAccountEvent extends SettingsEvent {
  final String password;

  ReauthenticateAndDeleteAccountEvent({required this.password});
}
