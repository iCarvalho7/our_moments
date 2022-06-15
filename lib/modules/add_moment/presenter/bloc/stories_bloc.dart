import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_state.dart';

@injectable
class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  StoriesBloc() : super(const HistoryStateInit()) {
    on<HistoryEventInit>(_init);
    on<HistoryEventOpenGallery>(_handleOpenGallery);
    on<HistoryEventAddPhotos>(_handleAddPhotos);
  }

  final List<String> photosList = [];

  FutureOr<void> _init(
    HistoryEventInit event,
    Emitter<StoriesState> emit,
  ) {
    photosList.clear();

    emit(
      HistoryStateUpdateHistory(photos: photosList),
    );
  }

  FutureOr<void> _handleOpenGallery(
    HistoryEventOpenGallery event,
    Emitter<StoriesState> emit,
  ) {
    emit(HistoryStateShowGallery());
  }

  FutureOr<void> _handleAddPhotos(
    HistoryEventAddPhotos event,
    Emitter<StoriesState> emit,
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
