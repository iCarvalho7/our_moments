part of 'add_or_edit_moment_bloc.dart';

abstract class AddOrEditMomentState {
  const AddOrEditMomentState();
}

class AddOrEditMomentStateEmpty extends AddOrEditMomentState {
  const AddOrEditMomentStateEmpty();
}

class AddOrEditMomentStateAllFilled extends AddOrEditMomentState {
  const AddOrEditMomentStateAllFilled();
}

class AddOrEditMomentStateCreate extends AddOrEditMomentState {
  final Moment moment;

  const AddOrEditMomentStateCreate({required this.moment});
}

class AddOrEditMomentStateEdit extends AddOrEditMomentState {
  final String momentID;

  const AddOrEditMomentStateEdit({required this.momentID});
}

class AddOrEditMomentStateLoading extends AddOrEditMomentState {
  const AddOrEditMomentStateLoading();
}

class AddOrEditMomentStateLoaded extends AddOrEditMomentState {
  final Moment moment;

  const AddOrEditMomentStateLoaded({required this.moment});
}

class AddOrEditMomentStateOpenGallery extends AddOrEditMomentState {
  const AddOrEditMomentStateOpenGallery();
}
