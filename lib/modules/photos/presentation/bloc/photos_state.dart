part of 'photos_bloc.dart';

abstract class PhotosState {
  const PhotosState();
}

class PhotosStateInit extends PhotosState {
  const PhotosStateInit();
}

class PhotosStateMediaFound extends PhotosState {
  PhotosStateMediaFound({required this.mediaFound});

  final List<Story> mediaFound;
}
