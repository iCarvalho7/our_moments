import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/logout_use_case.dart';

import '../../domain/entity/time_line.dart';
import '../../domain/use_case/get_time_line_from_email_use_case.dart';

part 'select_time_line_event.dart';

part 'select_time_line_state.dart';

@injectable
class SelectTimeLineBloc
    extends Bloc<SelectTimeLineEvent, SelectTimeLineState> {
  SelectTimeLineBloc(this._getTimeLineFromEmailUseCase, this._logoutUseCase)
      : super(SelectTimeLineInitial()) {
    on<SelectTimeLineEventFetchAll>(_fetchTimelines);
    on<SelectTimeLineEventLogout>(_logout);
  }

  final GetTimeLineFromEmailUseCase _getTimeLineFromEmailUseCase;
  final LogoutUseCase _logoutUseCase;

  FutureOr<void> _fetchTimelines(
    SelectTimeLineEventFetchAll event,
    Emitter<SelectTimeLineState> emit,
  ) async {
    emit(SelectTimeLineLoading());

    final result = await _getTimeLineFromEmailUseCase.call(NoParams.instance);

    if (result.isError) {
      emit(SelectTimeLineError(result.exception.toString()));
      return;
    }

    if (result.data!.isEmpty) {
      emit(SelectTimeLineEmpty());
      return;
    }

    emit(SelectTimeLineSuccess(result.data!));
  }

  FutureOr<void> _logout(
    SelectTimeLineEventLogout event,
    Emitter<SelectTimeLineState> emit,
  ) async {
    final result = await _logoutUseCase.call(NoParams.instance);
    if (result.isError) {
      emit(SelectTimeLogoutError());
    } else {
      emit(SelectTimeLogoutSuccess());
    }
  }
}
