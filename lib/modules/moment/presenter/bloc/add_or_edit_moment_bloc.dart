import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/moment.dart';
import '../../domain/entities/moment_type.dart';
import '../../domain/use_case/get_moment_by_id_use_case.dart';
import '../../domain/use_case/register_moments_use_case.dart';
import '../../../core/utils/string_ext/string_ext.dart';
import '../../domain/use_case/update_moment_use_case.dart';
import '../../../upload_photo/domain/use_case/upload_photo_use_case.dart';

part 'add_or_edit_moment_event.dart';

part 'add_or_edit_moment_state.dart';

@injectable
class AddOrEditMomentBloc extends Bloc<AddOrEditMomentEvent, AddOrEditMomentState> {
  final RegisterMomentsUseCase registerMomentsUseCase;
  final UploadPhotoUseCase uploadPhotoUseCase;
  final GetMomentByIdUseCase getMomentByIdUseCase;
  final UpdateMomentUseCase updateMomentUseCase;

  AddOrEditMomentBloc(
    this.updateMomentUseCase,
    this.registerMomentsUseCase,
    this.uploadPhotoUseCase,
    this.getMomentByIdUseCase,
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
      photos: state.photos,
      moment: state.moment.clone(
        type: event.type,
      ),
    ));
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleAddPhoto(
    AddOrEditMomentEventAddPhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    final photos = state.photos.toList()..addAll(event.photos);

    emit(AddOrEditMomentStateUpdate(photos: photos, moment: state.moment));

    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleDeletePhoto(
    AddOrEditMomentEventDeletePhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleAddTimeEvent(
    AddOrEditMomentEventAddDateTime event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      photos: state.photos,
      moment: state.moment.clone(
        dateTime: event.date,
        year: event.date.year.toString(),
        month: DateFormat(DateFormat.ABBR_MONTH, 'pt_BR').format(event.date),
        monthDay: event.date.day.toString(),
      ),
    ));
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleTypeTitle(
    AddOrEditMomentEventTypeTitle event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      photos: state.photos,
      moment: state.moment.clone(
        title: event.title,
      ),
    ));
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleTypeBodyText(
    AddOrEditMomentEvenTypeBodyText event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    emit(AddOrEditMomentStateUpdate(
      photos: state.photos,
      moment: state.moment.clone(
        body: event.bodyText,
      ),
    ));
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleCreateOrUpdateMoment(
    AddOrEditMomentEventCreateOrUpdateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateLoading(
      moment: state.moment,
      photos: state.photos,
    ));

    if (!state.moment.isEditing) {
      await _createMoment(emit);
    } else {
      await _editMoment(emit);
    }
  }

  Future<void> _createMoment(Emitter<AddOrEditMomentState> emit) async {
    final downloadUrlList =
        await uploadPhotoUseCase.call(state.photos, state.moment.id);
    emit(AddOrEditMomentStateUpdate(
      moment: state.moment.clone(downloadUrlList: downloadUrlList),
      photos: state.photos,
    ));
    await registerMomentsUseCase.call(state.moment);
  }

  FutureOr<void> _editMoment(Emitter<AddOrEditMomentState> emit) async {
    final downloadUrlList = await uploadPhotoUseCase.call(
      state.moment.downloadUrlList
          .where((element) => !element.isHttpUrl())
          .toList(),
      state.moment.id,
    );

    downloadUrlList.addAll(state.photos.where((element) => element.isHttpUrl()).toList());

    emit(
      AddOrEditMomentStateUpdate(
        photos: state.photos,
        moment: state.moment.clone(
          downloadUrlList: downloadUrlList,
        ),
      ),
    );

    await updateMomentUseCase.call(state.moment);
  }


  FutureOr<void> _handleEditMoment(
    SetupEditMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(AddOrEditMomentStateUpdate(
      moment: event.moment.clone(isEditing: true),
      photos: event.moment.downloadUrlList,
    ));
  }

  void _verifyIfFieldsAreFilled(Emitter<AddOrEditMomentState> emit) {
    if (_isAllFieldsFilled) {
      emit(AddOrEditMomentStateAllFilled(
        moment: state.moment,
        photos: state.photos,
      ));
      return;
    }
  }

  bool get _isAllFieldsFilled =>
      state.moment.dateTime != defaultDateTime &&
          state.photos.isNotEmpty &&
          state.moment.title.isNotEmpty &&
          state.moment.body.isNotEmpty;

  static final defaultDateTime = DateTime(0, 0, 0);
}
