part of 'add_or_edit_moment_bloc.dart';

abstract class AddOrEditMomentState {
  final Moment moment;
  final List<String> photosToDelete;

  const AddOrEditMomentState({required this.moment, required this.photosToDelete});
}

class AddOrEditMomentStateEmpty extends AddOrEditMomentState {
  final String timeLineId;

  AddOrEditMomentStateEmpty({required this.timeLineId}) : super(moment: Moment.empty(timeLineId), photosToDelete: []);
}

class AddOrEditMomentStateUpdate extends AddOrEditMomentState {
  const AddOrEditMomentStateUpdate({required super.moment, required super.photosToDelete});
}

class AddOrEditMomentStateCreate extends AddOrEditMomentState {
  const AddOrEditMomentStateCreate({required super.moment, required super.photosToDelete });
}

class AddOrEditMomentStateLoading extends AddOrEditMomentState {
  const AddOrEditMomentStateLoading({required super.moment, required super.photosToDelete});
}

/// Emitted when saving fails (e.g. an upload error). Carries the moment back so
/// the form is editable again instead of staying stuck on the loading state.
class AddOrEditMomentStateError extends AddOrEditMomentState {
  const AddOrEditMomentStateError({required super.moment, required super.photosToDelete});
}

class AddOrEditMomentStateDeleted extends AddOrEditMomentState {
  const AddOrEditMomentStateDeleted({required super.moment, required super.photosToDelete});
}
