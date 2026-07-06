import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/moment/domain/use_case/get_moments_use_case.dart';
import 'package:nossos_momentos/modules/user/domain/use_case/get_user_premium_use_case.dart';

import '../../../core/entity/result.dart';
import '../../../moment/domain/entities/moment.dart';
import '../../../moment/domain/use_case/delete_moments_use_case.dart';
import '../../../moment/domain/use_case/update_moment_use_case.dart';
import '../../../photos/domain/use_case/delete_all_photos_from_moment_use_case.dart';
import '../../domain/entity/time_line.dart';
import '../../domain/use_case/create_time_line_use_case.dart';
import '../../domain/use_case/get_time_line_from_id_use_case.dart';
import '../../domain/use_case/update_relationship_end_date_use_case.dart';
import '../../domain/use_case/update_relationship_start_date_use_case.dart';

part 'time_line_events.dart';
part 'time_line_state.dart';

@injectable
class TimeLineBloc extends Bloc<TimeLineEvent, TimeLineState> {
  final GetMomentsUseCase _getMomentsUseCase;
  final DeleteMomentsUseCase _deleteMomentsUseCase;
  final ClearAllPhotosFromMomentUseCase _deletePhotoUseCase;
  final CreateTimeLineUseCase _createTimeLineUseCase;
  final GetTimeLineFromIdUseCase _getTimeLineFromIdUseCase;
  final UpdateRelationshipStartDateUseCase _updateRelationshipStartDateUseCase;
  final UpdateRelationshipEndDateUseCase _updateRelationshipEndDateUseCase;
  final UpdateMomentUseCase _updateMomentUseCase;
  final PremiumService _premiumService;
  final GetUserPremiumUseCase _getUserPremiumUseCase;
  final AuthRepository _authRepository;
  late TimeLine timeLine;

  /// Email of the currently logged-in user; populated in [_init].
  String currentUserEmail = '';

  /// Every day (normalized, no time) that has at least one moment, across all
  /// months — used to mark dates in the calendar filter.
  List<DateTime> momentDates = [];

  /// All moments of the timeline (any date) — used by the moments map.
  List<Moment> allMoments = [];

  String get timelineId => timeLine.id;

  TimeLineBloc(
    this._getMomentsUseCase,
    this._deleteMomentsUseCase,
    this._deletePhotoUseCase,
    this._createTimeLineUseCase,
    this._getTimeLineFromIdUseCase,
    this._updateRelationshipStartDateUseCase,
    this._updateRelationshipEndDateUseCase,
    this._updateMomentUseCase,
    this._premiumService,
    this._getUserPremiumUseCase,
    this._authRepository,
  ) : super(TimeLineStateInitial()) {
    on<TimeLineEventInit>(_init);
    on<TimeLineEventChangeDate>(_handleChangeDate);
    on<TimeLineEventSetRelationshipDate>(_handleSetRelationshipDate);
    on<TimeLineEventSetRelationshipEndDate>(_handleSetRelationshipEndDate);
    on<TimeLineEventToggleFavorite>(_handleToggleFavorite);
    on<TimeLineEventChangeEyeToggle>(_handleChangeToggle);
    on<TimeLineEventDeleteMoment>(_deleteMoment);
    on<TimeLineEventReloadTimeline>(_handleReloadTimeline);
  }

  /// Re-fetches the [TimeLine] entity (name + accent color, emails) and reloads
  /// the moments. Used when returning from Settings, where these can change.
  FutureOr<void> _handleReloadTimeline(
    TimeLineEventReloadTimeline event,
    Emitter<TimeLineState> emit,
  ) async {
    final result = await _getTimeLineFromIdUseCase.call(timeLine.id);

    if (result.isSuccess && result.data != null) {
      timeLine = result.data!;
      _premiumService.bind(timeLine);
      await _bindUserPremium();
    }

    add(TimeLineEventChangeDate());
  }

  /// Loads the individual (per-user) premium entitlement and binds it on the
  /// [PremiumService]. Falls back to null (no individual premium) on failure,
  /// leaving the couple/timeline entitlement untouched.
  Future<void> _bindUserPremium() async {
    final result = await _getUserPremiumUseCase.call(NoParams.instance);
    _premiumService.bindUser(result.isSuccess ? result.data : null);
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

    Result<TimeLine> result;

    if (event.timeLineId == null) {
      result = await _createTimeLineUseCase.call(
        CreateTimeLineParams(momentEditPolicy: event.momentEditPolicy),
      );
    } else {
      result = await _getTimeLineFromIdUseCase.call(event.timeLineId!);
    }

    timeLine = result.data!;
    _premiumService.bind(timeLine);
    await _bindUserPremium();
    currentUserEmail = _authRepository.getCurrentUser()?.email ?? '';

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
      timelineId: timeLine.id,
      startDate: startDate,
      endDate: endDate,
    ));

    if (result.isSuccess && result.data!.isNotEmpty) {
      emit(
        TimeLineStateLoaded(
          momentsList: result.data!,
          startDate: startDate,
          endDate: endDate,
          isMonthEnabled: state.isMonthEnabled,
        ),
      );
      await _refreshMomentDates();
    } else {
      // Intervalo selecionado está vazio — busca todos os momentos para não
      // deixar o usuário sem nada para ver (ex: momentos só existem em anos
      // anteriores ao mês padrão exibido).
      await _refreshMomentDates();
      if (allMoments.isNotEmpty) {
        emit(
          TimeLineStateLoaded(
            momentsList: allMoments,
            startDate: kAllTimeStart,
            endDate: kAllTimeEnd,
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
  }

  /// Loads the dates of every moment in the timeline (any month) so the
  /// calendar filter can mark them.
  Future<void> _refreshMomentDates() async {
    final result = await _getMomentsUseCase.call(GetMomentsParam(
      timelineId: timeLine.id,
      startDate: kAllTimeStart,
      endDate: kAllTimeEnd,
    ));

    if (result.isSuccess && result.data != null) {
      allMoments = result.data!;
      momentDates = result.data!
          .map((m) => DateTime(m.dateTime.year, m.dateTime.month, m.dateTime.day))
          .toSet()
          .toList();
    }
  }

  FutureOr<void> _handleToggleFavorite(
    TimeLineEventToggleFavorite event,
    Emitter<TimeLineState> emit,
  ) async {
    final updated = event.moment.copyWith(isFavorite: !event.moment.isFavorite);
    await _updateMomentUseCase.call(updated);
    add(TimeLineEventChangeDate());
  }

  FutureOr<void> _handleSetRelationshipDate(
    TimeLineEventSetRelationshipDate event,
    Emitter<TimeLineState> emit,
  ) async {
    final result = await _updateRelationshipStartDateUseCase.call(
      UpdateRelationshipStartDateParams(timeline: timeLine, date: event.date),
    );

    if (result.isSuccess && result.data != null) {
      timeLine = result.data!;
      add(TimeLineEventChangeDate());
    }
  }

  FutureOr<void> _handleSetRelationshipEndDate(
    TimeLineEventSetRelationshipEndDate event,
    Emitter<TimeLineState> emit,
  ) async {
    final result = await _updateRelationshipEndDateUseCase.call(
      UpdateRelationshipEndDateParams(timeline: timeLine, date: event.date),
    );

    if (result.isSuccess && result.data != null) {
      timeLine = result.data!;
      add(TimeLineEventChangeDate());
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

  /// Sentinel usado quando não há filtro de data ativo (exibe todos os momentos).
  static final kAllTimeStart = DateTime(1);
  static final kAllTimeEnd = DateTime(9999);

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
