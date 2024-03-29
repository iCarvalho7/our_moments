part of 'select_time_line_bloc.dart';

sealed class SelectTimeLineState {}

final class SelectTimeLineInitial extends SelectTimeLineState {}

final class SelectTimeLineLoading extends SelectTimeLineState {}

final class SelectTimeLineSuccess extends SelectTimeLineState {
  final List<TimeLine> timeLines;

  SelectTimeLineSuccess(this.timeLines);
}

final class SelectTimeLineError extends SelectTimeLineState {}

final class SelectTimeLineEmpty extends SelectTimeLineState {}
