import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';

abstract class AddOrEditMomentEvent {
  const AddOrEditMomentEvent();
}

class SetupAddMomentEvent extends AddOrEditMomentEvent {
  SetupAddMomentEvent();
}

class SetupEditMomentEvent extends AddOrEditMomentEvent {
  final String momentID;
  const SetupEditMomentEvent({required this.momentID});
}

class AddOrEditMomentEventSelectType extends AddOrEditMomentEvent {
  final MomentType type;

  const AddOrEditMomentEventSelectType({
    required this.type,
  });
}

class AddOrEditMomentEventAddPhoto extends AddOrEditMomentEvent {
  final List<String> photos;

  const AddOrEditMomentEventAddPhoto({
    required this.photos,
  });
}

class AddOrEditMomentEventAddDateTime extends AddOrEditMomentEvent {
  final DateTime date;

  const AddOrEditMomentEventAddDateTime({
    required this.date,
  });
}

class AddOrEditMomentEventTypeTitle extends AddOrEditMomentEvent {
  final String title;

  const AddOrEditMomentEventTypeTitle({
    required this.title,
  });
}

class AddOrEditMomentEvenTypeBodyText extends AddOrEditMomentEvent {
  final String bodyText;

  const AddOrEditMomentEvenTypeBodyText({
    required this.bodyText,
  });
}

class AddOrEditMomentEventCreateOrUpdateMoment extends AddOrEditMomentEvent {
  const AddOrEditMomentEventCreateOrUpdateMoment();
}
