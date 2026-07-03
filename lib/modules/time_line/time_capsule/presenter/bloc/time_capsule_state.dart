part of 'time_capsule_bloc.dart';

class TimeCapsuleState {
  final String timelineId;
  final List<String> emails;
  final List<TimeCapsule> capsules;
  final bool isLoading;

  const TimeCapsuleState({
    required this.timelineId,
    required this.emails,
    required this.capsules,
    required this.isLoading,
  });

  const TimeCapsuleState.initial()
      : timelineId = '',
        emails = const [],
        capsules = const [],
        isLoading = false;

  TimeCapsuleState copyWith({
    String? timelineId,
    List<String>? emails,
    List<TimeCapsule>? capsules,
    bool? isLoading,
  }) {
    return TimeCapsuleState(
      timelineId: timelineId ?? this.timelineId,
      emails: emails ?? this.emails,
      capsules: capsules ?? this.capsules,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
