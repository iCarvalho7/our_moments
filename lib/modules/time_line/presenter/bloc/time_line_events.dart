part of 'time_line_bloc.dart';

abstract class TimeLineEvent {
  const TimeLineEvent();
}

class TimeLineEventInit extends TimeLineEvent {
  const TimeLineEventInit({
    required this.timeLineId,
    this.momentEditPolicy = 'individual',
  });

  final String? timeLineId;

  /// Used only when [timeLineId] is null (creating a new timeline).
  final String momentEditPolicy;
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

class TimeLineEventSetRelationshipEndDate extends TimeLineEvent {
  final DateTime? date;

  const TimeLineEventSetRelationshipEndDate({this.date});
}

class TimeLineEventToggleFavorite extends TimeLineEvent {
  final Moment moment;

  const TimeLineEventToggleFavorite({required this.moment});
}

class TimeLineEventReloadTimeline extends TimeLineEvent {
  const TimeLineEventReloadTimeline();
}
