part of 'add_or_edit_moment_bloc.dart';

abstract class AddOrEditMomentState {
  final Moment moment;

  const AddOrEditMomentState({required this.moment});
}

class AddOrEditMomentStateEmpty extends AddOrEditMomentState {
  AddOrEditMomentStateEmpty() : super(moment: Moment.empty());
}

class AddOrEditMomentStateUpdate extends AddOrEditMomentState {
  const AddOrEditMomentStateUpdate({required super.moment});
}

class AddOrEditMomentStateCreate extends AddOrEditMomentState {
  const AddOrEditMomentStateCreate({required super.moment});
}

class AddOrEditMomentStateLoading extends AddOrEditMomentState {
  const AddOrEditMomentStateLoading({required super.moment});
}

class AddOrEditMomentStateLoaded extends AddOrEditMomentState {
  const AddOrEditMomentStateLoaded({required super.moment});
}

class AddOrEditMomentStateOpenGallery extends AddOrEditMomentState {
  const AddOrEditMomentStateOpenGallery({required super.moment});
}
