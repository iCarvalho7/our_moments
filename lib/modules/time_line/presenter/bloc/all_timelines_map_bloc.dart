import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/repository/time_line_repository.dart';
import 'package:nossos_momentos/modules/time_line/domain/use_case/get_time_line_from_email_use_case.dart';

part 'all_timelines_map_event.dart';
part 'all_timelines_map_state.dart';

@injectable
class AllTimelinesMapBloc
    extends Bloc<AllTimelinesMapEvent, AllTimelinesMapState> {
  AllTimelinesMapBloc(
    this._getTimeLineFromEmailUseCase,
    this._timeLineRepository,
  ) : super(AllTimelinesMapInitial()) {
    on<FetchAllTimelinesMapEvent>(_fetch);
  }

  final GetTimeLineFromEmailUseCase _getTimeLineFromEmailUseCase;
  final TimeLineRepository _timeLineRepository;

  FutureOr<void> _fetch(
    FetchAllTimelinesMapEvent event,
    Emitter<AllTimelinesMapState> emit,
  ) async {
    emit(AllTimelinesMapLoading());

    final timelinesResult =
        await _getTimeLineFromEmailUseCase.call(NoParams.instance);
    if (timelinesResult.isError) {
      emit(AllTimelinesMapError(timelinesResult.exception.toString()));
      return;
    }

    final timelines = timelinesResult.data!;
    if (timelines.isEmpty) {
      emit(AllTimelinesMapEmpty());
      return;
    }

    final now = DateTime.now();
    // Fetch the full history — use a far-past start date so nothing is missed.
    final startDate = DateTime(1990);
    final allMoments = <Moment>[];

    for (final timeline in timelines) {
      try {
        final moments = await _timeLineRepository.getMomentsByDate(
          startDate: startDate,
          endDate: now,
          timeLineId: timeline.id,
        );
        allMoments.addAll(moments);
      } catch (_) {}
    }

    allMoments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final timelineColors = {for (final t in timelines) t.id: t.accentColor};

    if (allMoments.isEmpty) {
      emit(AllTimelinesMapEmpty());
      return;
    }

    emit(AllTimelinesMapSuccess(
      timelines: timelines,
      moments: allMoments,
      timelineAccentColors: timelineColors,
    ));
  }
}

