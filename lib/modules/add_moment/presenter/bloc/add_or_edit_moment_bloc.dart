import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/add_moment/domain/use_case/register_moments_use_case.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_state.dart';
import 'package:uuid/uuid.dart';

@injectable
class AddOrEditMomentBloc
    extends Bloc<AddOrEditMomentEvent, AddOrEditMomentState> {
  final RegisterMomentsUseCase useCase;

  MomentType type = MomentType.romantic;
  DateTime date = defaultDateTime;
  List<String> photos = [];
  String title = '';
  String bodyText = '';

  AddOrEditMomentBloc(this.useCase)
      : super(AddOrEditMomentStateLoading()) {
    on<SetupAddMomentEvent>(_handleShowEmpty);
    on<AddOrEditMomentEventSelectType>(_handleSelectType);
    on<AddOrEditMomentEventAddPhoto>(_handleAddPhoto);
    on<AddOrEditMomentEventAddDateTime>(_handleAddTimeEvent);
    on<AddOrEditMomentEventTypeTitle>(_handleTypeTitle);
    on<AddOrEditMomentEvenTypeBodyText>(_handleTypeBodyText);
    on<AddOrEditMomentEventCreateMoment>(_handleCreateMoment);
  }

  FutureOr<void> _handleShowEmpty(
    SetupAddMomentEvent event,
    Emitter<AddOrEditMomentState> emit,
  ) {
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

  FutureOr<void> _handleCreateMoment(
    AddOrEditMomentEventCreateMoment event,
    Emitter<AddOrEditMomentState> emit,
  ) async {
    final moment = Moment(
      id: const Uuid().v1(),
      title: title,
      body: bodyText,
      photosList: photos,
      type: type,
      dateTime: date,
    );
    emit(AddOrEditMomentStateLoading());

    await Future.delayed(const Duration(seconds: 3));

    final result = await useCase.call(moment);

    emit(AddOrEditMomentStateLoaded(moment: moment));

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

  static final defaultDateTime = DateTime(0, 0, 0);
}
