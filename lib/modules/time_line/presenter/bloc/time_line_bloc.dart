import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_events.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_state.dart';

import '../../domain/use_case/delete_moments_use_case.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase getMomentsUseCase;
  final DeleteMomentsUseCase _deleteMomentsUseCase;

  String year = enabledYears.first;
  String month = monthsName.first;
  bool isMonthEnabled = true;

  TimeLineBloc(
    this.getMomentsUseCase,
    this._deleteMomentsUseCase,
  ) : super(const TimeLineStateLoading()) {
    on<TimeLineEventInit>(_init);
    on<TimeLineEventChangeDate>(_handleChangeDate);
    on<TimeLineEventChangeEyeToggle>(_handleChangeToggle);
    on<TimeLineEventDeleteMoment>(_deleteMoment);
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
      emit(const TimeLineStateEmpty());
    } else {
      emit(
        TimeLineStateLoaded(momentsList: result),
      );
    }
    emit(const TimeLineStateToggleMonth(isMonthEnabled: true));
  }

  FutureOr<void> _handleChangeDate(
    TimeLineEventChangeDate event,
    Emitter<TimeLineState> emit,
  ) async {
    emit(const TimeLineStateLoading());

    year = event.year ?? year;
    final tempMonth = isMonthEnabled ? event.month ?? month : '';

    final filteredMoments = await getMomentsUseCase.call(
      year: year,
      month: tempMonth,
    );

    if (filteredMoments.isEmpty) {
      emit(const TimeLineStateEmpty());
    } else {
      emit(TimeLineStateLoaded(momentsList: filteredMoments));
    }
  }

  FutureOr<void> _handleChangeToggle(
    TimeLineEventChangeEyeToggle event,
    Emitter<TimeLineState> emit,
  ) async {
    isMonthEnabled = !isMonthEnabled;
    emit(TimeLineStateToggleMonth(isMonthEnabled: isMonthEnabled));
    add(TimeLineEventChangeDate(year: year));
  }

  FutureOr<void> _deleteMoment(
    TimeLineEventDeleteMoment event,
    Emitter<TimeLineState> emit,
  ) async {
    await _deleteMomentsUseCase.call(event.momentId);
    add(const TimeLineEventChangeDate());
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
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];
}
