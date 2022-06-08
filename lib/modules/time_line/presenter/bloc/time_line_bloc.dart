import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_events.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_state.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase getMomentsUseCase;

  int year = defaultYear;
  String month = monthsName.first;

  TimeLineBloc(this.getMomentsUseCase) : super(const TimeLineStateLoading()) {
    on<TimeLineEventInit>(_init);
    on<TimeLineEventChangeDate>(_handleChangeDate);
  }

  FutureOr<void> _init(
    TimeLineEventInit event,
    Emitter<TimeLineState> emit,
  ) async {
    emit(
      const TimeLineStateLoading(),
    );

    Future.delayed(const Duration(seconds: 4));

    final result = await getMomentsUseCase.call(
      year: defaultYear,
      month: month,
    );
    if (result.isEmpty) {
      emit(const TimeLineStateEmpty());
    } else {
      emit(
        TimeLineStateLoaded(
          momentsList: result,
        ),
      );
    }
  }

  FutureOr<void> _handleChangeDate(
    TimeLineEventChangeDate event,
    Emitter<TimeLineState> emit,
  ) async {

    final filteredMoments = await getMomentsUseCase.call(
      year: event.year != null ? int.parse(event.year!) : year,
      month: event.month ?? month,
    );

    if (filteredMoments.isEmpty) {
      //emit(const TimeLineStateEmpty());
    } else {
      emit(
        TimeLineStateLoaded(
          momentsList: filteredMoments,
        ),
      );
    }
  }

  static const defaultYear = 2018;
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
