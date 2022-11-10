import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'photos_event.dart';

part 'photos_state.dart';

@injectable
class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc() : super(const PhotosStateInit()) {
    on<PhotosEventInit>(_init);
    on<PhotosEventOpenGallery>(_openGallery);
    on<PhotosEventAddPhotos>(_addPhotos);
    on<PhotosEventDeletePhoto>(_deletePhoto);
  }

  final List<String> photosList = [];

  FutureOr<void> _init(
    PhotosEventInit event,
    Emitter<PhotosState> emit,
  ) {
    photosList.clear();
    emit(PhotosStateUpdateHistory(photos: photosList));
  }

  FutureOr<void> _openGallery(
    PhotosEventOpenGallery event,
    Emitter<PhotosState> emit,
  ) {
    emit(PhotosStateShowGallery());
  }

  FutureOr<void> _addPhotos(
    PhotosEventAddPhotos event,
    Emitter<PhotosState> emit,
  ) {
    if (event.needClearList) {
      photosList.clear();
    }

    photosList.addAll(event.photos);
    emit(PhotosStateUpdateHistory(photos: photosList));
  }

  FutureOr<void> _deletePhoto(
    PhotosEventDeletePhoto event,
    Emitter<PhotosState> emit,
  ) {
    photosList.remove(event.photo);
    emit(PhotosStateUpdateHistory(photos: photosList));
  }
}
