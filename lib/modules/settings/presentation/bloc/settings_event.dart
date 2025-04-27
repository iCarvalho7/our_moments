part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class FetchEmailEvent extends SettingsEvent {
  final TimeLine timeLine;

  FetchEmailEvent({required this.timeLine});
}

class DeleteEmailEvent extends SettingsEvent {
  final String email;

  DeleteEmailEvent({required this.email});
}

class AddEmailEvent extends SettingsEvent {
  final String email;

  AddEmailEvent({required this.email});
}
