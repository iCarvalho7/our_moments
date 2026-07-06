part of 'new_feed_cubit.dart';

sealed class NewFeedState {}

final class NewFeedInitial extends NewFeedState {}

final class NewFeedLoading extends NewFeedState {}

final class NewFeedLoaded extends NewFeedState {
  final List<TimeLine> timelines;
  final List<Moment> moments;
  final String? activeTimelineId;
  final String currentUserEmail;

  NewFeedLoaded({
    required this.timelines,
    required this.moments,
    required this.activeTimelineId,
    required this.currentUserEmail,
  });
}

final class NewFeedError extends NewFeedState {
  final String error;
  NewFeedError(this.error);
}
