abstract class PhotosEvent {
  const PhotosEvent();
}

class PhotosEventInit extends PhotosEvent {
  PhotosEventInit();
}

class PhotosEventOpenGallery extends PhotosEvent {
  PhotosEventOpenGallery();
}

class PhotosEventAddPhotos extends PhotosEvent {
  final List<String> photos;
  final bool needClearList;

  PhotosEventAddPhotos({
    required this.photos,
    this.needClearList = false,
  });
}
