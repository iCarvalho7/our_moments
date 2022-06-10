import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const HistoryStateInit()) {
    on<HistoryEventInit>(_init);
    on<HistoryEventOpenGallery>(_handleOpenGallery);
    on<HistoryEventAddPhotos>(_handleAddPhotos);
  }

  final List<String> photosList = [];

  FutureOr<void> _init(
    HistoryEventInit event,
    Emitter<HistoryState> emit,
  ) {
    photosList.clear();

    emit(
      HistoryStateUpdateHistory(photos: photosList),
    );
  }

  FutureOr<void> _handleOpenGallery(
    HistoryEventOpenGallery event,
    Emitter<HistoryState> emit,
  ) {
    emit(HistoryStateShowGallery());
  }

  FutureOr<void> _handleAddPhotos(
    HistoryEventAddPhotos event,
    Emitter<HistoryState> emit,
  ) {
    if (event.needClearList) {
      photosList.clear();
    }

    photosList.addAll(event.photos);

    emit(
      HistoryStateUpdateHistory(photos: photosList),
    );
  }
}
