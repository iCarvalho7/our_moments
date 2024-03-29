import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_month_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_year_use_case.dart';

import '../../../moment/domain/entities/moment.dart';
import '../../../photos/domain/use_case/delete_all_photos_from_moment_use_case.dart';
import '../../../moment/domain/use_case/delete_moments_use_case.dart';

part 'time_line_events.dart';

part 'time_line_state.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase _getMomentsUseCase;
  final GetMonthUseCase _getMonthUseCase;
  final GetYearUseCase _getYearUseCase;
  final DeleteMomentsUseCase _deleteMomentsUseCase;
  final ClearAllPhotosFromMomentUseCase _deletePhotoUseCase;

  TimeLineBloc(
    this._getMomentsUseCase,
    this._getMonthUseCase,
    this._getYearUseCase,
    this._deleteMomentsUseCase,
    this._deletePhotoUseCase,
  ) : super(TimeLineStateInitial()) {
    on<TimeLineEventInit>(_init);
    on<TimeLineEventChangeDate>(_handleChangeDate);
    on<TimeLineEventChangeEyeToggle>(_handleChangeToggle);
    on<TimeLineEventDeleteMoment>(_deleteMoment);
  }

  FutureOr<void> _init(
    TimeLineEventInit event,
    Emitter<TimeLineState> emit,
  ) async {
    String year = _getYearUseCase(NoParams.instance).data!;
    String month = _getMonthUseCase(NoParams.instance).data!;
    emit(TimeLineStateLoading(
      year: year,
      month: month,
      isMonthEnabled: state.isMonthEnabled,
    ));
    add(TimeLineEventChangeDate(year: year, month: month));
  }

  FutureOr<void> _handleChangeDate(
    TimeLineEventChangeDate event,
    Emitter<TimeLineState> emit,
  ) async {
    emit(
      TimeLineStateLoading(
        year: state.year,
        month: state.month,
        isMonthEnabled: event.disableMonth ?? state.isMonthEnabled,
      ),
    );

    final year = event.year ?? state.year;
    final month = !state.isMonthEnabled ? null : event.month ?? state.month;

    final result = await _getMomentsUseCase.call(GetMomentsParam(
      year: year,
      month: month,
    ));

    if (result.isSuccess && result.data!.isEmpty == false) {
      emit(
        TimeLineStateLoaded(
          momentsList: result.data!,
          year: year,
          month: month ?? state.month,
          isMonthEnabled: state.isMonthEnabled,
        ),
      );
    } else {
      emit(
        TimeLineStateEmpty(
          year: year,
          month: month ?? state.month,
          isMonthEnabled: state.isMonthEnabled,
        ),
      );
    }
  }

  FutureOr<void> _handleChangeToggle(
    TimeLineEventChangeEyeToggle event,
    Emitter<TimeLineState> emit,
  ) async {
    add(TimeLineEventChangeDate(disableMonth: !state.isMonthEnabled));
  }

  FutureOr<void> _deleteMoment(
    TimeLineEventDeleteMoment event,
    Emitter<TimeLineState> emit,
  ) async {
    final result = await _deletePhotoUseCase.call(event.momentId);
    if (result.isSuccess) {
      await _deleteMomentsUseCase.call(event.momentId);
    }

    add(const TimeLineEventChangeDate());
  }

  static const enabledYears = [
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
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
