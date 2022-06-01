import 'package:nossos_momentos/modules/time_line/domain/entities/moment.dart';

abstract class TimeLineState {
  const TimeLineState();
}

class TimeLineStateLoading extends TimeLineState {
  const TimeLineStateLoading();
}

class TimeLineStateLoaded extends TimeLineState {
  final List<Moment> momentsList;

  const TimeLineStateLoaded({
    required this.momentsList,
  });
}

class TimeLineStateEmpty extends TimeLineState {

  const TimeLineStateEmpty();
}
