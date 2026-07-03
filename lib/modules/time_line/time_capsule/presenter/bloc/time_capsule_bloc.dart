import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/time_capsule.dart';
import '../../domain/use_case/add_time_capsule_use_case.dart';
import '../../domain/use_case/remove_time_capsule_use_case.dart';
import '../../domain/use_case/watch_time_capsules_use_case.dart';

part 'time_capsule_event.dart';

part 'time_capsule_state.dart';

@injectable
class TimeCapsuleBloc extends Bloc<TimeCapsuleEvent, TimeCapsuleState> {
  final WatchTimeCapsulesUseCase watchTimeCapsulesUseCase;
  final AddTimeCapsuleUseCase addTimeCapsuleUseCase;
  final RemoveTimeCapsuleUseCase removeTimeCapsuleUseCase;

  StreamSubscription<List<TimeCapsule>>? _subscription;

  TimeCapsuleBloc(
    this.watchTimeCapsulesUseCase,
    this.addTimeCapsuleUseCase,
    this.removeTimeCapsuleUseCase,
  ) : super(const TimeCapsuleState.initial()) {
    on<TimeCapsuleStarted>(_onStarted);
    on<TimeCapsuleUpdated>(_onUpdated);
    on<TimeCapsuleAdded>(_onAdded);
    on<TimeCapsuleRemoved>(_onRemoved);
  }

  FutureOr<void> _onStarted(
    TimeCapsuleStarted event,
    Emitter<TimeCapsuleState> emit,
  ) {
    emit(state.copyWith(
      timelineId: event.timelineId,
      emails: event.emails,
      isLoading: true,
    ));

    _subscription?.cancel();
    _subscription = watchTimeCapsulesUseCase.call(event.timelineId).listen(
          (capsules) => add(TimeCapsuleUpdated(capsules)),
        );
  }

  FutureOr<void> _onUpdated(
    TimeCapsuleUpdated event,
    Emitter<TimeCapsuleState> emit,
  ) {
    emit(state.copyWith(capsules: event.capsules, isLoading: false));
  }

  FutureOr<void> _onAdded(
    TimeCapsuleAdded event,
    Emitter<TimeCapsuleState> emit,
  ) async {
    await addTimeCapsuleUseCase.call(AddTimeCapsuleParams(
      timelineId: state.timelineId,
      message: event.message,
      revealDate: event.revealDate,
      mediaUrl: event.mediaUrl,
      emails: state.emails,
    ));
  }

  FutureOr<void> _onRemoved(
    TimeCapsuleRemoved event,
    Emitter<TimeCapsuleState> emit,
  ) async {
    await removeTimeCapsuleUseCase.call(RemoveTimeCapsuleParams(
      timelineId: state.timelineId,
      id: event.id,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
