part of 'all_timelines_map_bloc.dart';

abstract class AllTimelinesMapState {}

class AllTimelinesMapInitial extends AllTimelinesMapState {}

class AllTimelinesMapLoading extends AllTimelinesMapState {}

class AllTimelinesMapEmpty extends AllTimelinesMapState {}

class AllTimelinesMapError extends AllTimelinesMapState {
  final String message;
  AllTimelinesMapError(this.message);
}

class AllTimelinesMapSuccess extends AllTimelinesMapState {
  final List<TimeLine> timelines;

  /// All moments from all timelines, sorted newest-first.
  final List<Moment> moments;

  /// Maps timeline ID → accentColor (nullable int). Resolved to Color in the widget.
  final Map<String, int?> timelineAccentColors;

  AllTimelinesMapSuccess({
    required this.timelines,
    required this.moments,
    required this.timelineAccentColors,
  });
}
