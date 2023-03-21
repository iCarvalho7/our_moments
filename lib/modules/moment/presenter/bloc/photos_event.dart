part of 'photos_bloc.dart';

abstract class PhotosEvent {
  const PhotosEvent();
}

class PhotosEventInit extends PhotosEvent {
  PhotosEventInit();
}

class PhotosEventOpenGallery extends PhotosEvent {
  PhotosEventOpenGallery();
}