abstract class TimeLineEvent {
  const TimeLineEvent();
}

class TimeLineEventInit extends TimeLineEvent {
  const TimeLineEventInit();
}

class TimeLineEventChangeDate extends TimeLineEvent {
  final String? year;
  final String? month;

  const TimeLineEventChangeDate({
    this.year,
    this.month,
  });
}

class TimeLineEventDisableMonth extends TimeLineEvent {
  const TimeLineEventDisableMonth();
}

class TimeLineEventDeleteMoment extends TimeLineEvent {
  final String momentId;

  const TimeLineEventDeleteMoment({
    required this.momentId,
  });
}
