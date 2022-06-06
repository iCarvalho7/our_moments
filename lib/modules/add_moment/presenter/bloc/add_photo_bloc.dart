import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_photo_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const HistoryStateInit()) {
    on<AddPhotoEventOpenGallery>(_handleOpenGallery);
    on<AddPhotoEventAddPhotos>(_handleAddPhotos);
  }

  final List<String> photosList = [];

  FutureOr<void> _handleOpenGallery(
    AddPhotoEventOpenGallery event,
    Emitter<HistoryState> emit,
  ) {
    emit(HistoryStateShowGallery());

    emit(
      HistoryStateUpdateHistory(photos: photosList),
    );
  }

  FutureOr<void> _handleAddPhotos(
    AddPhotoEventAddPhotos event,
    Emitter<HistoryState> emit,
  ) {
    photosList.addAll(event.photos);

    emit(
      HistoryStateUpdateHistory(photos: photosList),
    );
  }
}
