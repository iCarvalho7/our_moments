import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';

abstract class TimeLineState {
  const TimeLineState();
}

class TimeLineStateLoading extends TimeLineState {
  const TimeLineStateLoading();
}

class TimeLineStateLoaded extends TimeLineState {
  final List<Moment> momentsList;

  const TimeLineStateLoaded({required this.momentsList});
}

class TimeLineStateToggleMonth extends TimeLineState {
  const TimeLineStateToggleMonth({this.isMonthEnabled = true});

  final bool isMonthEnabled;
}

class TimeLineStateEmpty extends TimeLineState {
  const TimeLineStateEmpty();
}
