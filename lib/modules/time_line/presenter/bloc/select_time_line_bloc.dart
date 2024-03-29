import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../../domain/entity/time_line.dart';
import '../../domain/use_case/get_time_line_from_email_use_case.dart';

part 'select_time_line_event.dart';

part 'select_time_line_state.dart';

@injectable
class SelectTimeLineBloc extends Bloc<SelectTimeLineEvent, SelectTimeLineState> {
  SelectTimeLineBloc(this._getTimeLineFromEmailUseCase)
      : super(SelectTimeLineInitial()) {
    on<SelectTimeLineEventFetchAll>(_fetchTimelines);
  }

  final GetTimeLineFromEmailUseCase _getTimeLineFromEmailUseCase;

  FutureOr<void> _fetchTimelines(
    SelectTimeLineEventFetchAll event,
    Emitter<SelectTimeLineState> emit,
  ) async {
    emit(SelectTimeLineLoading());

    final result = await _getTimeLineFromEmailUseCase.call(NoParams.instance);

    if (result.isError) {
      emit(SelectTimeLineError());
      return;
    }

    if (result.data!.isEmpty) {
      emit(SelectTimeLineEmpty());
      return;
    }

    emit(SelectTimeLineSuccess(result.data!));
  }
}
