part of 'time_line_bloc.dart';

abstract class TimeLineEvent {
  const TimeLineEvent();
}

class TimeLineEventInit extends TimeLineEvent {
  const TimeLineEventInit({required this.timeLine});

  final TimeLine? timeLine;
}

class TimeLineEventChangeDate extends TimeLineEvent {
  final bool? disableMonth;
  final DateTime? startDate;
  final DateTime? endDate;

  const TimeLineEventChangeDate({
    this.startDate,
    this.endDate,
    this.disableMonth,
  });
}

class TimeLineEventChangeEyeToggle extends TimeLineEvent {
  const TimeLineEventChangeEyeToggle();
}

class TimeLineEventDeleteMoment extends TimeLineEvent {
  final String momentId;

  const TimeLineEventDeleteMoment({required this.momentId});
}
