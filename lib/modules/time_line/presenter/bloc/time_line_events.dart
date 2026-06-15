part of 'time_line_bloc.dart';

abstract class TimeLineEvent {
  const TimeLineEvent();
}

class TimeLineEventInit extends TimeLineEvent {
  const TimeLineEventInit({required this.timeLineId});

  final String? timeLineId;
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

class TimeLineEventSetRelationshipDate extends TimeLineEvent {
  final DateTime date;

  const TimeLineEventSetRelationshipDate({required this.date});
}

class TimeLineEventToggleFavorite extends TimeLineEvent {
  final Moment moment;

  const TimeLineEventToggleFavorite({required this.moment});
}

class TimeLineEventReloadTimeline extends TimeLineEvent {
  const TimeLineEventReloadTimeline();
}
