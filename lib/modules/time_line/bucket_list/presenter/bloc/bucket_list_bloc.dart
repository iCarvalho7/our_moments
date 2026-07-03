import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/bucket_item.dart';
import '../../domain/use_case/add_bucket_item_use_case.dart';
import '../../domain/use_case/remove_bucket_item_use_case.dart';
import '../../domain/use_case/toggle_bucket_item_use_case.dart';
import '../../domain/use_case/watch_bucket_list_use_case.dart';

part 'bucket_list_event.dart';

part 'bucket_list_state.dart';

@injectable
class BucketListBloc extends Bloc<BucketListEvent, BucketListState> {
  final WatchBucketListUseCase watchBucketListUseCase;
  final AddBucketItemUseCase addBucketItemUseCase;
  final ToggleBucketItemUseCase toggleBucketItemUseCase;
  final RemoveBucketItemUseCase removeBucketItemUseCase;

  StreamSubscription<List<BucketItem>>? _subscription;

  BucketListBloc(
    this.watchBucketListUseCase,
    this.addBucketItemUseCase,
    this.toggleBucketItemUseCase,
    this.removeBucketItemUseCase,
  ) : super(const BucketListState.initial()) {
    on<BucketListStarted>(_onStarted);
    on<BucketListUpdated>(_onUpdated);
    on<BucketListItemAdded>(_onItemAdded);
    on<BucketListItemToggled>(_onItemToggled);
    on<BucketListItemRemoved>(_onItemRemoved);
  }

  FutureOr<void> _onStarted(
    BucketListStarted event,
    Emitter<BucketListState> emit,
  ) {
    emit(state.copyWith(timelineId: event.timelineId, isLoading: true));

    _subscription?.cancel();
    _subscription = watchBucketListUseCase.call(event.timelineId).listen(
          (items) => add(BucketListUpdated(items)),
        );
  }

  FutureOr<void> _onUpdated(
    BucketListUpdated event,
    Emitter<BucketListState> emit,
  ) {
    emit(state.copyWith(items: event.items, isLoading: false));
  }

  FutureOr<void> _onItemAdded(
    BucketListItemAdded event,
    Emitter<BucketListState> emit,
  ) async {
    await addBucketItemUseCase.call(AddBucketItemParams(
      timelineId: state.timelineId,
      title: event.title,
      category: event.category,
      notes: event.notes,
    ));
  }

  FutureOr<void> _onItemToggled(
    BucketListItemToggled event,
    Emitter<BucketListState> emit,
  ) async {
    await toggleBucketItemUseCase.call(ToggleBucketItemParams(
      timelineId: state.timelineId,
      id: event.id,
      done: event.done,
    ));
  }

  FutureOr<void> _onItemRemoved(
    BucketListItemRemoved event,
    Emitter<BucketListState> emit,
  ) async {
    await removeBucketItemUseCase.call(RemoveBucketItemParams(
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
