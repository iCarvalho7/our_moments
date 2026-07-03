part of 'add_or_edit_moment_bloc.dart';

abstract class AddOrEditMomentEvent {
  const AddOrEditMomentEvent();
}

class SetupAddMomentEvent extends AddOrEditMomentEvent {
  final String timelineId;

  const SetupAddMomentEvent({required this.timelineId});
}

class SetupEditMomentEvent extends AddOrEditMomentEvent {
  final Moment moment;

  const SetupEditMomentEvent({required this.moment});
}

class AddOrEditMomentEventSelectType extends AddOrEditMomentEvent {
  final MomentType type;

  const AddOrEditMomentEventSelectType({
    required this.type,
  });
}

class AddOrEditMomentEventAddMedia extends AddOrEditMomentEvent {
  final List<String> medias;

  const AddOrEditMomentEventAddMedia({required this.medias});
}

class AddOrEditMomentEventDeletePhoto extends AddOrEditMomentEvent {
  final String photo;

  const AddOrEditMomentEventDeletePhoto({required this.photo});
}

class AddOrEditMomentEventAddDateTime extends AddOrEditMomentEvent {
  final DateTime date;

  const AddOrEditMomentEventAddDateTime({
    required this.date,
  });
}

class AddOrEditMomentEventTypeTitle extends AddOrEditMomentEvent {
  final String title;

  const AddOrEditMomentEventTypeTitle({required this.title});
}

class AddOrEditMomentEvenTypeBodyText extends AddOrEditMomentEvent {
  final String bodyText;

  const AddOrEditMomentEvenTypeBodyText({
    required this.bodyText,
  });
}

class AddOrEditMomentEventTypeLocation extends AddOrEditMomentEvent {
  final String location;

  const AddOrEditMomentEventTypeLocation({required this.location});
}

class AddOrEditMomentEventSetLocation extends AddOrEditMomentEvent {
  final double latitude;
  final double longitude;
  final String name;

  const AddOrEditMomentEventSetLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

class AddOrEditMomentEventSetAudio extends AddOrEditMomentEvent {
  final String path;

  const AddOrEditMomentEventSetAudio({required this.path});
}

class AddOrEditMomentEventRemoveAudio extends AddOrEditMomentEvent {
  const AddOrEditMomentEventRemoveAudio();
}

class AddOrEditMomentEventCreateOrUpdateMoment extends AddOrEditMomentEvent {
  const AddOrEditMomentEventCreateOrUpdateMoment();
}

class AddOrEditMomentEventDeleteMoment extends AddOrEditMomentEvent {
  const AddOrEditMomentEventDeleteMoment();
}
