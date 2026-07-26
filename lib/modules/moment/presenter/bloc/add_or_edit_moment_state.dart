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

/// Emitted when a brand-new moment is saved successfully. Distinct from
/// [AddOrEditMomentStateUpdate] (edit success) so the page can celebrate a
/// creation with confetti before popping. Carries how big the celebration
/// should feel and an optional achievement title unlocked by this moment.
class AddOrEditMomentStateCreate extends AddOrEditMomentState {
  final CelebrationTier celebrationTier;
  final String? achievementTitle;

  const AddOrEditMomentStateCreate({
    required super.moment,
    required super.photosToDelete,
    this.celebrationTier = CelebrationTier.standard,
    this.achievementTitle,
  });
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
