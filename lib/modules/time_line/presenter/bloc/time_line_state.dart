part of 'time_line_bloc.dart';

abstract class TimeLineState {
  final String year;
  final String month;
  final bool isMonthEnabled;

  TimeLineState({required this.year, required this.month, required this.isMonthEnabled});

}

class TimeLineStateInitial extends TimeLineState {
  TimeLineStateInitial() : super(year: '', month: '', isMonthEnabled: true);
}

class TimeLineStateLoading extends TimeLineState {
  TimeLineStateLoading({required super.year, required super.month, required super.isMonthEnabled});
}

class TimeLineStateLoaded extends TimeLineState {
  final List<Moment> momentsList;

  TimeLineStateLoaded({required this.momentsList, required super.year, required super.month, required super.isMonthEnabled});
}

class TimeLineStateEmpty extends TimeLineState {
  TimeLineStateEmpty({required super.year, required super.month, required super.isMonthEnabled});
}
