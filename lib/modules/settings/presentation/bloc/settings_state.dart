part of 'settings_bloc.dart';

sealed class SettingsState {
  final TimeLine? timeLine;
  final String? email;

  SettingsState({required this.timeLine, required this.email});
}

final class SettingsLoading extends SettingsState {
  SettingsLoading({required super.timeLine, required super.email});
}

final class SettingsSuccess extends SettingsState {
  SettingsSuccess({required super.timeLine, required super.email});
}

final class SettingsError extends SettingsState {
  SettingsError({required super.timeLine, required super.email});
}

final class SettingsTimeLineDeleted extends SettingsState {
  SettingsTimeLineDeleted({required super.timeLine, required super.email});
}

/// The account and its data were deleted; the UI should route to login.
final class SettingsAccountDeleted extends SettingsState {
  SettingsAccountDeleted({required super.timeLine, required super.email});
}

/// Firebase requires a recent login before deleting the account; the UI should
/// prompt for the password and dispatch [ReauthenticateAndDeleteAccountEvent].
final class SettingsReauthRequired extends SettingsState {
  SettingsReauthRequired({required super.timeLine, required super.email});
}

/// Deleting the account failed (and it was not a reauth requirement).
final class SettingsAccountDeleteError extends SettingsState {
  SettingsAccountDeleteError({required super.timeLine, required super.email});
}

/// The user signed out; the UI should route to login.
final class SettingsLoggedOut extends SettingsState {
  SettingsLoggedOut({required super.timeLine, required super.email});
}
