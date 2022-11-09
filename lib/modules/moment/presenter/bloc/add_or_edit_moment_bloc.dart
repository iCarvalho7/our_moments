import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
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
class AddOrEditMomentBloc
    extends Bloc<AddOrEditMomentEvent, AddOrEditMomentState> {
  final RegisterMomentsUseCase registerMomentsUseCase;
  final UploadPhotoUseCase uploadPhotoUseCase;
  final GetMomentByIdUseCase getMomentByIdUseCase;
  final UpdateMomentUseCase updateMomentUseCase;

  bool isAddMoment = false;

  MomentType type = MomentType.bad;
  DateTime date = defaultDateTime;
  List<String> photos = [];
  String title = '';
  String bodyText = '';
  late Moment currentMoment;

  AddOrEditMomentBloc(
    this.updateMomentUseCase,
    this.registerMomentsUseCase,
    this.uploadPhotoUseCase,
    this.getMomentByIdUseCase,
  ) : super(const AddOrEditMomentStateLoading()) {
    on<SetupAddMomentEvent>(_handleShowEmpty);
    on<SetupEditMomentEvent>(_handleEditMoment);
    on<AddOrEditMomentEventSelectType>(_handleSelectType);
    on<AddOrEditMomentEventAddPhoto>(_handleAddPhoto);
    on<AddOrEditMomentEventAddDateTime>(_handleAddTimeEvent);
    on<AddOrEditMomentEventTypeTitle>(_handleTypeTitle);
    on<AddOrEditMomentEvenTypeBodyText>(_handleTypeBodyText);
    on<AddOrEditMomentEventCreateOrUpdateMoment>(_handleCreateOrUpdateMoment);
  }

  FutureOr<void> _handleShowEmpty(
    SetupAddMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    type = MomentType.bad;
    date = defaultDateTime;
    photos.clear();
    title = '';
    bodyText = '';
    isAddMoment = true;
    emit(const AddOrEditMomentStateEmpty());
  }

  FutureOr<void> _handleSelectType(
    AddOrEditMomentEventSelectType event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    type = event.type;
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleAddPhoto(
    AddOrEditMomentEventAddPhoto event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    photos.addAll(event.photos);
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleAddTimeEvent(
    AddOrEditMomentEventAddDateTime event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    date = event.date;
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleTypeTitle(
    AddOrEditMomentEventTypeTitle event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    title = event.title;
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleTypeBodyText(
    AddOrEditMomentEvenTypeBodyText event,
    Emitter<AddOrEditMomentState> emit,
  ) {
    bodyText = event.bodyText;
    _verifyIfFieldsAreFilled(emit);
  }

  FutureOr<void> _handleCreateOrUpdateMoment(
    AddOrEditMomentEventCreateOrUpdateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    emit(const AddOrEditMomentStateLoading());

    if (isAddMoment) {
      await _createMoment();
    } else {
      await _editMoment();
    }

    add(SetupAddMomentEvent());
  }

  Future<void> _createMoment() async {
    final momentId = const Uuid().v1();

    final downloadUrlList = await uploadPhotoUseCase.call(photos, momentId);

    final moment = Moment(
        id: momentId,
        title: title,
        body: bodyText,
        downloadUrlList: downloadUrlList,
        type: type,
        dateTime: date,
        year: date.year.toString(),
        month: DateFormat(DateFormat.ABBR_MONTH, 'pt_BR').format(date),
        monthDay: date.day.toString());

    await registerMomentsUseCase.call(moment);
  }

  FutureOr<void> _handleEditMoment(
    SetupEditMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    isAddMoment = false;
    emit(const AddOrEditMomentStateLoading());

    currentMoment = await getMomentByIdUseCase.call(event.momentID);

    date = currentMoment.dateTime;
    photos = currentMoment.downloadUrlList;
    title = currentMoment.title;
    bodyText = currentMoment.body;

    _verifyIfFieldsAreFilled(emit);

    emit(AddOrEditMomentStateLoaded(moment: currentMoment));
  }

  bool get _isAllFieldsFilled =>
      date != defaultDateTime &&
      photos.isNotEmpty &&
      title.isNotEmpty &&
      bodyText.isNotEmpty;

  void _verifyIfFieldsAreFilled(Emitter<AddOrEditMomentState> emit) {
    if (_isAllFieldsFilled) {
      emit(
        const AddOrEditMomentStateAllFilled(),
      );
    }
  }

  FutureOr<void> _editMoment() async {
    final downloadUrlList = await uploadPhotoUseCase.call(
      photos.where((element) => !element.isHttpUrl()).toList(),
      currentMoment.id,
    );

    downloadUrlList
        .addAll(photos.where((element) => element.isHttpUrl()).toList());

    final moment = Moment(
      id: currentMoment.id,
      title: title,
      body: bodyText,
      downloadUrlList: downloadUrlList,
      type: type,
      dateTime: date,
      year: date.year.toString(),
      month: DateFormat(DateFormat.MONTH, 'pt_BR').format(date),
      monthDay: date.day.toString(),
    );

    await updateMomentUseCase.call(moment);
  }

  static final defaultDateTime = DateTime(0, 0, 0);

}
