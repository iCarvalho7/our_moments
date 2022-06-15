abstract class PhotosState {
  const PhotosState();
}

class PhotosStateInit extends PhotosState {
  const PhotosStateInit();
}

class PhotosStateShowGallery extends PhotosState {
  PhotosStateShowGallery();
}

class PhotosStateUpdateHistory extends PhotosState {
  final List<String> photos;

  const PhotosStateUpdateHistory({required this.photos});
}
