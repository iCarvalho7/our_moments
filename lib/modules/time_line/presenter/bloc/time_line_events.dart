part of 'time_line_bloc.dart';

abstract class TimeLineEvent {
  const TimeLineEvent();
}

class TimeLineEventInit extends TimeLineEvent {
  const TimeLineEventInit();
}

class TimeLineEventChangeDate extends TimeLineEvent {
  final String? year;
  final String? month;
  final bool? disableMonth;

  const TimeLineEventChangeDate({this.year, this.month, this.disableMonth});
}

class TimeLineEventChangeEyeToggle extends TimeLineEvent {
  const TimeLineEventChangeEyeToggle();
}

class TimeLineEventDeleteMoment extends TimeLineEvent {
  final String momentId;

  const TimeLineEventDeleteMoment({required this.momentId});
}
