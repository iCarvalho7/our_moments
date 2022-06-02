import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

abstract class TimeLineState {
  const TimeLineState();
}

class TimeLineStateLoading extends TimeLineState {
  const TimeLineStateLoading();
}

class TimeLineStateLoaded extends TimeLineState {
  final List<TimeLineMoment> momentsList;

  const TimeLineStateLoaded({
    required this.momentsList,
  });
}

class TimeLineStateEmpty extends TimeLineState {

  const TimeLineStateEmpty();
}
