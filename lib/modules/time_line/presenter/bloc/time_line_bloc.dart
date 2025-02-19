import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_month_use_case.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_year_use_case.dart';

import '../../../moment/domain/entities/moment.dart';
import '../../../moment/domain/use_case/delete_moments_use_case.dart';
import '../../../photos/domain/use_case/delete_all_photos_from_moment_use_case.dart';
import '../../domain/entity/time_line.dart';
import '../../domain/use_case/create_time_line_use_case.dart';

part 'time_line_events.dart';

part 'time_line_state.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase _getMomentsUseCase;
  final DeleteMomentsUseCase _deleteMomentsUseCase;
  final ClearAllPhotosFromMomentUseCase _deletePhotoUseCase;
  final CreateTimeLineUseCase _createTimeLineUseCase;
  late TimeLine _timeLine;

  String get timelineId => _timeLine.id;

  TimeLineBloc(
    this._getMomentsUseCase,
    this._deleteMomentsUseCase,
    this._deletePhotoUseCase,
    this._createTimeLineUseCase,
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
    emit(TimeLineStateLoading(
      startDate: state.startDate,
      endDate: state.endDate,
      isMonthEnabled: state.isMonthEnabled,
    ));

    if (event.timeLine == null) {
      final result = await _createTimeLineUseCase.call(NoParams.instance);
      if (result.isSuccess) {
        _timeLine = result.data!;
      }
    } else {
      _timeLine = event.timeLine!;
    }

    add(TimeLineEventChangeDate());
  }

  FutureOr<void> _handleChangeDate(
    TimeLineEventChangeDate event,
    Emitter<TimeLineState> emit,
  ) async {
    final startDate = event.startDate ?? state.startDate;
    final endDate = event.endDate ?? state.endDate;

    emit(
      TimeLineStateLoading(
        startDate: startDate,
        endDate: endDate,
        isMonthEnabled: event.disableMonth ?? state.isMonthEnabled,
      ),
    );

    final result = await _getMomentsUseCase.call(GetMomentsParam(
      timelineId: _timeLine.id,
      startDate: startDate,
      endDate: endDate,
    ));

    if (result.isSuccess && result.data!.isEmpty == false) {
      emit(
        TimeLineStateLoaded(
          momentsList: result.data!,
          startDate: startDate,
          endDate: endDate,
          isMonthEnabled: state.isMonthEnabled,
        ),
      );
    } else {
      emit(
        TimeLineStateEmpty(
          startDate: startDate,
          endDate: endDate,
          isMonthEnabled: state.isMonthEnabled,
        ),
      );
    }
  }

  FutureOr<void> _handleChangeToggle(
    TimeLineEventChangeEyeToggle event,
    Emitter<TimeLineState> emit,
  ) async {
    // add(TimeLineEventChangeDate(disableMonth: !state.isMonthEnabled));
  }

  FutureOr<void> _deleteMoment(
    TimeLineEventDeleteMoment event,
    Emitter<TimeLineState> emit,
  ) async {
    final result = await _deletePhotoUseCase.call(event.momentId);
    if (result.isSuccess) {
      await _deleteMomentsUseCase.call(event.momentId);
    }

    add(TimeLineEventChangeDate());
  }

  static const enabledYears = [
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
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
