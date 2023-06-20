import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';

import '../../../stories/domain/entity/story.dart';
import '../../domain/use_case/get_media_use_case.dart';

part 'photos_event.dart';
part 'photos_state.dart';

@injectable
class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {

  final GetMediaUseCase _getMediaUseCase;

  PhotosBloc(this._getMediaUseCase) : super(const PhotosStateInit()) {
    on<PhotosEventOpenGallery>(_openGallery);
  }

  FutureOr<void> _openGallery(
    PhotosEventOpenGallery event,
    Emitter<PhotosState> emit,
  ) async {
    final result = await _getMediaUseCase(NoParams.instance);

    if (result.isSuccess && result.data!.isNotEmpty) {
      emit(PhotosStateMediaFound(mediaFound: result.data!));
    }
  }
}
