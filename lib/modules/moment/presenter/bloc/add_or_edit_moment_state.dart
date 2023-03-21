part of 'add_or_edit_moment_bloc.dart';

abstract class AddOrEditMomentState {
  final Moment moment;
  final List<String> photos;

  const AddOrEditMomentState({
    required this.moment,
    required this.photos,
  });
}

class AddOrEditMomentStateEmpty extends AddOrEditMomentState {
  AddOrEditMomentStateEmpty()
      : super(
          moment: Moment.empty(),
          photos: List.empty(),
        );
}

class AddOrEditMomentStateUpdate extends AddOrEditMomentState {
  const AddOrEditMomentStateUpdate({
    required super.moment,
    required super.photos,
  });
}

class AddOrEditMomentStateAllFilled extends AddOrEditMomentState {
  const AddOrEditMomentStateAllFilled({
    required super.moment,
    required super.photos,
  });
}

class AddOrEditMomentStateCreate extends AddOrEditMomentState {
  const AddOrEditMomentStateCreate({
    required super.moment,
    required super.photos,
  });
}

class AddOrEditMomentStateLoading extends AddOrEditMomentState {
  const AddOrEditMomentStateLoading({
    required super.moment,
    required super.photos,
  });
}

class AddOrEditMomentStateLoaded extends AddOrEditMomentState {
  const AddOrEditMomentStateLoaded({
    required super.moment,
    required super.photos,
  });
}

class AddOrEditMomentStateOpenGallery extends AddOrEditMomentState {
  const AddOrEditMomentStateOpenGallery({
    required super.moment,
    required super.photos
  });
}
