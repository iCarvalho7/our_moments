import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/login/domain/repository/auth_repository.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/moment/domain/use_case/get_moments_use_case.dart';

import '../../domain/entity/time_line.dart';
import '../../domain/use_case/get_time_line_from_email_use_case.dart';

part 'new_feed_state.dart';

/// Aggregates every timeline the user belongs to and their moments into a single
/// social feed. Keeps mutable internal state (all moments + timelines) so the
/// timeline filter can run locally without re-fetching from the backend.
@injectable
class NewFeedCubit extends Cubit<NewFeedState> {
  final GetTimeLineFromEmailUseCase _getTimeLineFromEmailUseCase;
  final GetMomentsUseCase _getMomentsUseCase;
  final AuthRepository _authRepository;

  NewFeedCubit(
    this._getTimeLineFromEmailUseCase,
    this._getMomentsUseCase,
    this._authRepository,
  ) : super(NewFeedInitial());

  /// How far back to fetch moments for the feed.
  static const _lookbackYears = 5;

  List<Moment> _allMoments = [];
  List<TimeLine> _timelines = [];
  String _currentUserEmail = '';
  String? _activeTimelineId;

  Future<void> load() async {
    if (state is! NewFeedLoaded) emit(NewFeedLoading());
    try {
      final currentUserEmail = _authRepository.getCurrentUser()?.email ?? '';

      final timelineResult =
          await _getTimeLineFromEmailUseCase.call(NoParams.instance);
      if (timelineResult.isError) {
        emit(NewFeedError(timelineResult.exception.toString()));
        return;
      }
      final timelines = timelineResult.data ?? [];

      final now = DateTime.now();
      final startDate = DateTime(now.year - _lookbackYears, now.month, now.day);

      final results = await Future.wait(
        timelines.map(
          (timeline) => _getMomentsUseCase.call(GetMomentsParam(
            startDate: startDate,
            endDate: now,
            timelineId: timeline.id,
          )),
        ),
      );

      final moments = <Moment>[];
      for (final result in results) {
        if (result.isSuccess && result.data != null) {
          moments.addAll(result.data!);
        }
      }
      moments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      _allMoments = moments;
      _timelines = timelines;
      _currentUserEmail = currentUserEmail;

      final filtered = _activeTimelineId == null
          ? moments
          : moments.where((m) => m.timelineId == _activeTimelineId).toList();

      emit(NewFeedLoaded(
        timelines: timelines,
        moments: filtered,
        activeTimelineId: _activeTimelineId,
        currentUserEmail: currentUserEmail,
      ));
    } catch (error) {
      emit(NewFeedError(error.toString()));
    }
  }

  /// Filters the already-loaded moments by timeline without hitting the backend.
  /// Passing null clears the filter (shows every timeline's moments).
  void filterByTimeline(String? id) {
    _activeTimelineId = id;
    final moments = id == null
        ? _allMoments
        : _allMoments.where((m) => m.timelineId == id).toList();

    emit(NewFeedLoaded(
      timelines: _timelines,
      moments: moments,
      activeTimelineId: id,
      currentUserEmail: _currentUserEmail,
    ));
  }
}
