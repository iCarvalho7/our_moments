import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

abstract class TimeLineState {
  final bool isMonthEnabled;

  const TimeLineState({this.isMonthEnabled = true});
}

class TimeLineStateLoading extends TimeLineState {
  const TimeLineStateLoading();
}

class TimeLineStateLoaded extends TimeLineState {
  final List<TimeLineMoment> momentsList;

  const TimeLineStateLoaded({
    required this.momentsList,
    required bool isMonthEnabled,
  }) : super(isMonthEnabled: isMonthEnabled);
}

class TimeLineStateEmpty extends TimeLineState {
  const TimeLineStateEmpty({required bool isMonthEnabled})
      : super(isMonthEnabled: isMonthEnabled);
}
