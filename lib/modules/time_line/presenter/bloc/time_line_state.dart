part of 'time_line_bloc.dart';

abstract class TimeLineState {
  final DateTime startDate;
  final DateTime endDate;
  final bool isMonthEnabled;

  TimeLineState({required this.startDate, required this.endDate, required this.isMonthEnabled});
}

class TimeLineStateInitial extends TimeLineState {
  TimeLineStateInitial()
      : super(
          startDate: _currentDateOnly(),
          endDate: _nextMonthDate(),
          isMonthEnabled: true,
        );

  static DateTime _currentDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static DateTime _nextMonthDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1);
  }
}

class TimeLineStateLoading extends TimeLineState {
  TimeLineStateLoading({required super.startDate, required super.endDate, required super.isMonthEnabled});
}

class TimeLineStateLoaded extends TimeLineState {
  final List<Moment> momentsList;

  TimeLineStateLoaded(
      {required this.momentsList, required super.startDate, required super.endDate, required super.isMonthEnabled});
}

class TimeLineStateEmpty extends TimeLineState {
  TimeLineStateEmpty({required super.startDate, required super.endDate, required super.isMonthEnabled});
}
