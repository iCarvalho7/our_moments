abstract class HistoryEvent {
  const HistoryEvent();
}

class AddPhotoEventOpenGallery extends HistoryEvent {
  AddPhotoEventOpenGallery();
}

class AddPhotoEventAddPhotos extends HistoryEvent {
  List<String> photos;

  AddPhotoEventAddPhotos({required this.photos});
}
