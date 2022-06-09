import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_events.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_state.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase getMomentsUseCase;

  String year = enabledYears.first;
  String month = monthsName.first;
  bool isMonthEnabled = true;

  TimeLineBloc(this.getMomentsUseCase) : super(const TimeLineStateLoading()) {
    on<TimeLineEventInit>(_init);
    on<TimeLineEventChangeDate>(_handleChangeDate);
    on<TimeLineEventChangeEyeToggle>(_handleChangeToggle);
  }

  FutureOr<void> _init(
    TimeLineEventInit event,
    Emitter<TimeLineState> emit,
  ) async {
    emit(const TimeLineStateLoading());

    final result = await getMomentsUseCase.call(
      year: year,
      month: month,
    );

    if (result.isEmpty) {
      emit(TimeLineStateEmpty(isMonthEnabled: isMonthEnabled,));
    } else {
      emit(
        TimeLineStateLoaded(
          momentsList: result,
          isMonthEnabled: isMonthEnabled,
        ),
      );
    }
  }

  FutureOr<void> _handleChangeDate(
    TimeLineEventChangeDate event,
    Emitter<TimeLineState> emit,
  ) async {
    year = event.year ?? year;
    month = isMonthEnabled ? event.month ?? month : '';

    final filteredMoments = await getMomentsUseCase.call(
      year: year,
      month: month,
    );

    if (filteredMoments.isEmpty) {
      emit(TimeLineStateEmpty(isMonthEnabled: isMonthEnabled));
    } else {
      emit(
        TimeLineStateLoaded(
          momentsList: filteredMoments,
          isMonthEnabled: isMonthEnabled,
        ),
      );
    }
  }

  FutureOr<void> _handleChangeToggle(
    TimeLineEventChangeEyeToggle event,
    Emitter<TimeLineState> emit,
  ) async {
    month = '';
    isMonthEnabled = !isMonthEnabled;
  }

  static const enabledYears = [
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024'
  ];

  static const monthsName = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
}
