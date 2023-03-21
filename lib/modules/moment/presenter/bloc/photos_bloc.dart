import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'photos_event.dart';

part 'photos_state.dart';

@injectable
class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc() : super(const PhotosStateInit()) {
    on<PhotosEventOpenGallery>(_openGallery);
  }

  FutureOr<void> _openGallery(
    PhotosEventOpenGallery event,
    Emitter<PhotosState> emit,
  ) {
    emit(PhotosStateShowGallery());
  }
}
