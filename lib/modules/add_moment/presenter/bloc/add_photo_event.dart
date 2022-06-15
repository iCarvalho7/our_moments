abstract class StoriesEvent {
  const StoriesEvent();
}

class HistoryEventInit extends StoriesEvent {
  HistoryEventInit();
}

class HistoryEventOpenGallery extends StoriesEvent {
  HistoryEventOpenGallery();
}

class HistoryEventAddPhotos extends StoriesEvent {
  final List<String> photos;
  final bool needClearList;

  HistoryEventAddPhotos({
    required this.photos,
    this.needClearList = false,
  });
}
