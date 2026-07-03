part of 'special_dates_bloc.dart';

class SpecialDatesState {
  final String timelineId;
  final List<SpecialDate> dates;
  final bool isLoading;

  const SpecialDatesState({
    required this.timelineId,
    required this.dates,
    required this.isLoading,
  });

  const SpecialDatesState.initial()
      : timelineId = '',
        dates = const [],
        isLoading = false;

  SpecialDatesState copyWith({
    String? timelineId,
    List<SpecialDate>? dates,
    bool? isLoading,
  }) {
    return SpecialDatesState(
      timelineId: timelineId ?? this.timelineId,
      dates: dates ?? this.dates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
