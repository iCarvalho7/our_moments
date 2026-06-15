import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/add_email_use_case.dart';
import 'package:nossos_momentos/modules/settings/domain/use_case/delete_email_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_time_line_from_id_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/update_time_line_details_use_case.dart';

import '../../domain/use_case/get_current_user_use_case.dart';

part 'settings_event.dart';

part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this.addEmailUseCase,
    this.deleteEmailUseCase,
    this.getCurrentUserUseCase,
    this._getTimeLineFromIdUseCase,
    this._updateTimeLineDetailsUseCase,
  ) : super(SettingsLoading(timeLine: null, email: null)) {
    on<FetchEmailEvent>(_init);
    on<AddEmailEvent>(_addEmail);
    on<DeleteEmailEvent>(_deleteEmail);
    on<UpdateTimeLineDetailsEvent>(_updateDetails);
  }

  final AddEmailUseCase addEmailUseCase;
  final DeleteEmailUseCase deleteEmailUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetTimeLineFromIdUseCase _getTimeLineFromIdUseCase;
  final UpdateTimeLineDetailsUseCase _updateTimeLineDetailsUseCase;

  FutureOr<void> _init(
    FetchEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final res = getCurrentUserUseCase.call(NoParams.instance);
    final timelineRes = await _getTimeLineFromIdUseCase.call(event.timeLineId);

    if (res.isSuccess && res.data != null && timelineRes.isSuccess) {
      emit(SettingsSuccess(timeLine: timelineRes.data!, email: res.data!.email));
    }
  }

  FutureOr<void> _addEmail(
    AddEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final res = await addEmailUseCase.call(EmailParam(email: event.email, timeline: state.timeLine!));
    if (res.isError || res.data == null) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    emit(SettingsSuccess(timeLine: res.data!, email: state.email));
  }

  FutureOr<void> _deleteEmail(
    DeleteEmailEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(timeLine: state.timeLine, email: state.email));

    final res = await deleteEmailUseCase.call(EmailParam(email: event.email, timeline: state.timeLine!));
    if (res.isError) {
      emit(SettingsError(timeLine: state.timeLine, email: state.email));
      return;
    }
    emit(SettingsSuccess(timeLine: res.data!, email: state.email));
  }

  FutureOr<void> _updateDetails(
    UpdateTimeLineDetailsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final res = await _updateTimeLineDetailsUseCase.call(UpdateTimeLineDetailsParams(
      timeline: state.timeLine!,
      name: event.name,
      accentColor: event.accentColor,
    ));
    if (res.isSuccess && res.data != null) {
      emit(SettingsSuccess(timeLine: res.data!, email: state.email));
    }
  }
}
