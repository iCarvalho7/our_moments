import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/special_date.dart';
import '../../domain/use_case/add_special_date_use_case.dart';
import '../../domain/use_case/remove_special_date_use_case.dart';
import '../../domain/use_case/watch_special_dates_use_case.dart';

part 'special_dates_event.dart';

part 'special_dates_state.dart';

@injectable
class SpecialDatesBloc extends Bloc<SpecialDatesEvent, SpecialDatesState> {
  final WatchSpecialDatesUseCase watchSpecialDatesUseCase;
  final AddSpecialDateUseCase addSpecialDateUseCase;
  final RemoveSpecialDateUseCase removeSpecialDateUseCase;

  StreamSubscription<List<SpecialDate>>? _subscription;

  SpecialDatesBloc(
    this.watchSpecialDatesUseCase,
    this.addSpecialDateUseCase,
    this.removeSpecialDateUseCase,
  ) : super(const SpecialDatesState.initial()) {
    on<SpecialDatesStarted>(_onStarted);
    on<SpecialDatesUpdated>(_onUpdated);
    on<SpecialDateAdded>(_onAdded);
    on<SpecialDateRemoved>(_onRemoved);
  }

  FutureOr<void> _onStarted(
    SpecialDatesStarted event,
    Emitter<SpecialDatesState> emit,
  ) {
    emit(state.copyWith(timelineId: event.timelineId, isLoading: true));

    _subscription?.cancel();
    _subscription = watchSpecialDatesUseCase.call(event.timelineId).listen(
          (dates) => add(SpecialDatesUpdated(dates)),
        );
  }

  FutureOr<void> _onUpdated(
    SpecialDatesUpdated event,
    Emitter<SpecialDatesState> emit,
  ) {
    emit(state.copyWith(dates: event.dates, isLoading: false));
  }

  FutureOr<void> _onAdded(
    SpecialDateAdded event,
    Emitter<SpecialDatesState> emit,
  ) async {
    await addSpecialDateUseCase.call(AddSpecialDateParams(
      timelineId: state.timelineId,
      title: event.title,
      date: event.date,
      remindDaysBefore: event.remindDaysBefore,
    ));
  }

  FutureOr<void> _onRemoved(
    SpecialDateRemoved event,
    Emitter<SpecialDatesState> emit,
  ) async {
    await removeSpecialDateUseCase.call(RemoveSpecialDateParams(
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
