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
