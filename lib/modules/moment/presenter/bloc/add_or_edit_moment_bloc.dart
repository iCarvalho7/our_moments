// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';
import '../../../photos/domain/use_case/delete_photo_use_case.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/moment_type.dart';
import '../../domain/use_case/register_moments_use_case.dart';
import '../../domain/use_case/update_moment_use_case.dart';
import '../../../photos/domain/use_case/upload_photo_use_case.dart';

part 'add_or_edit_moment_event.dart';

part 'add_or_edit_moment_state.dart';

@injectable
class AddOrEditMomentBloc extends Bloc<AddOrEditMomentEvent, AddOrEditMomentState> {
  final RegisterMomentsUseCase registerMomentsUseCase;
  final UploadPhotoUseCase uploadPhotoUseCase;
  final UpdateMomentUseCase updateMomentUseCase;
  final DeletePhotoUseCase deletePhotoUseCase;

  AddOrEditMomentBloc(
    this.updateMomentUseCase,
    this.registerMomentsUseCase,
    this.uploadPhotoUseCase,
    this.deletePhotoUseCase,
  ) : super(AddOrEditMomentStateEmpty()) {
    on<SetupAddMomentEvent>(_handleShowEmpty);
    on<SetupEditMomentEvent>(_handleEditMoment);
    on<AddOrEditMomentEventSelectType>(_handleSelectType);
    on<AddOrEditMomentEventAddMedia>(_handleAddPhoto);
    on<AddOrEditMomentEventDeletePhoto>(_handleDeletePhoto);
    on<AddOrEditMomentEventAddDateTime>(_handleAddTimeEvent);
    on<AddOrEditMomentEventTypeTitle>(_handleTypeTitle);
    on<AddOrEditMomentEvenTypeBodyText>(_handleTypeBodyText);
    on<AddOrEditMomentEventCreateOrUpdateMoment>(_handleCreateOrUpdateMoment);
  }

  FutureOr<void> _handleShowEmpty(
    SetupAddMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateEmpty());
  }

  FutureOr<void> _handleSelectType(
    AddOrEditMomentEventSelectType event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        type: event.type,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleAddPhoto(
    AddOrEditMomentEventAddMedia event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final photos = state.moment.downloadUrlList.toList()..addAll(event.medias);

    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(downloadUrlList: photos),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleDeletePhoto(
    AddOrEditMomentEventDeletePhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final newList = state.moment.downloadUrlList;
    newList.remove(event.photo);
    emit(
      AddOrEditMomentStateUpdate(
        moment: state.moment.copyWith(downloadUrlList: newList),
        photosToDelete:
            event.photo.isHttpUrl ? [...state.photosToDelete, event.photo] : state.photosToDelete,
      ),
    );
  }

  FutureOr<void> _handleAddTimeEvent(
    AddOrEditMomentEventAddDateTime event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        dateTime: event.date,
        year: event.date.year.toString(),
        month: DateFormat(DateFormat.ABBR_MONTH, 'pt_BR').format(event.date),
        monthDay: event.date.day.toString(),
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleTypeTitle(
    AddOrEditMomentEventTypeTitle event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        title: event.title,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleTypeBodyText(
    AddOrEditMomentEvenTypeBodyText event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(
        body: event.bodyText,
      ),
      photosToDelete: state.photosToDelete,
    ));
  }

  FutureOr<void> _handleCreateOrUpdateMoment(
    AddOrEditMomentEventCreateOrUpdateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateLoading(moment: state.moment, photosToDelete: state.photosToDelete));

    if (!state.moment.isEditing) {
      await _createMoment(emit);
    } else {
      await _editMoment(emit);
    }
  }

  Future<void> _createMoment(Emitter<AddOrEditMomentState> emit) async {
    final result = await uploadPhotoUseCase.call(PhotoParams(
      paths: state.moment.localImgList,
      momentId: state.moment.id,
    ));

    if (result.isSuccess) {
      final uploadedImgList = state.moment.uploadedImgList;
      final moment = state.moment.copyWith(downloadUrlList: result.data!..addAll(uploadedImgList));
      await registerMomentsUseCase.call(moment);
      emit(AddOrEditMomentStateUpdate(
        moment: moment,
        photosToDelete: [],
      ));
    }
  }

  FutureOr<void> _editMoment(Emitter<AddOrEditMomentState> emit) async {
    final deleteResult = await deletePhotoUseCase(PhotoParams(
      paths: state.photosToDelete,
      momentId: state.moment.id,
    ));

    final result = await uploadPhotoUseCase(PhotoParams(
      paths: state.moment.localImgList,
      momentId: state.moment.id,
    ));

    if (result.isSuccess && deleteResult.isSuccess) {
      final editedMoment = state.moment.copyWith(
        downloadUrlList: result.data!..addAll(state.moment.uploadedImgList),
      );
      await updateMomentUseCase(editedMoment);

      emit(AddOrEditMomentStateUpdate(
        moment: editedMoment,
        photosToDelete: [],
      ));
    }
  }

  FutureOr<void> _handleEditMoment(
    SetupEditMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateUpdate(
      moment: event.moment.copyWith(isEditing: true),
      photosToDelete: state.photosToDelete,
    ));
  }

  static final defaultDateTime = DateTime(0, 0, 0);
}
