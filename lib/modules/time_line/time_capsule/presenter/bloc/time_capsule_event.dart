part of 'time_capsule_bloc.dart';

abstract class TimeCapsuleEvent {
  const TimeCapsuleEvent();
}

class TimeCapsuleStarted extends TimeCapsuleEvent {
  final String timelineId;
  final List<String> emails;

  const TimeCapsuleStarted({required this.timelineId, required this.emails});
}

class TimeCapsuleUpdated extends TimeCapsuleEvent {
  final List<TimeCapsule> capsules;

  const TimeCapsuleUpdated(this.capsules);
}

class TimeCapsuleAdded extends TimeCapsuleEvent {
  final String message;
  final DateTime revealDate;
  final String mediaUrl;

  const TimeCapsuleAdded({
    required this.message,
    required this.revealDate,
    this.mediaUrl = '',
  });
}

class TimeCapsuleRemoved extends TimeCapsuleEvent {
  final String id;

  const TimeCapsuleRemoved(this.id);
}
