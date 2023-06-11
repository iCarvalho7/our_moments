import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
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

  AddOrEditMomentBloc(
    this.updateMomentUseCase,
    this.registerMomentsUseCase,
    this.uploadPhotoUseCase,
  ) : super(AddOrEditMomentStateEmpty()) {
    on<SetupAddMomentEvent>(_handleShowEmpty);
    on<SetupEditMomentEvent>(_handleEditMoment);
    on<AddOrEditMomentEventSelectType>(_handleSelectType);
    on<AddOrEditMomentEventAddPhoto>(_handleAddPhoto);
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
    ));
  }

  FutureOr<void> _handleAddPhoto(
    AddOrEditMomentEventAddPhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final photos = state.moment.downloadUrlList.toList()..addAll(event.photos);

    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.copyWith(downloadUrlList: photos),
    ));

  }

  FutureOr<void> _handleDeletePhoto(
    AddOrEditMomentEventDeletePhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
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
    ));
  }

  FutureOr<void> _handleCreateOrUpdateMoment(
    AddOrEditMomentEventCreateOrUpdateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateLoading(moment: state.moment));

    if (!state.moment.isEditing) {
      await _createMoment(emit);
    } else {
      await _editMoment(emit);
    }
  }

  Future<void> _createMoment(Emitter<AddOrEditMomentState> emit) async {
    final result = await uploadPhotoUseCase.call(UploadPhotoParams(
      paths: state.moment.localImgList,
      momentId: state.moment.id,
    ));

    if (result.isSuccess) {
      final uploadedImgList = state.moment.uploadedImgList;
      final moment = state.moment.copyWith(downloadUrlList: result.data!..addAll(uploadedImgList));
      await registerMomentsUseCase.call(moment);
      emit(AddOrEditMomentStateUpdate(moment: moment));
    }
  }

  FutureOr<void> _editMoment(Emitter<AddOrEditMomentState> emit) async {
    final localImageList = state.moment.localImgList;

    final result = await uploadPhotoUseCase.call(UploadPhotoParams(
      paths: localImageList,
      momentId: state.moment.id,
    ));

    if (result.isSuccess) {
      final editedMoment = state.moment.copyWith(
        downloadUrlList: result.data!..addAll(state.moment.uploadedImgList),
      );
      await updateMomentUseCase.call(editedMoment);

      emit(AddOrEditMomentStateUpdate(moment: editedMoment));
    }
  }

  FutureOr<void> _handleEditMoment(
    SetupEditMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateUpdate(moment: event.moment.copyWith(isEditing: true)));
  }

  static final defaultDateTime = DateTime(0, 0, 0);
}
