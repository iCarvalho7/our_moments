abstract class HistoryEvent {
  const HistoryEvent();
}

class HistoryEventInit extends HistoryEvent {
  HistoryEventInit();
}

class HistoryEventOpenGallery extends HistoryEvent {
  HistoryEventOpenGallery();
}

class HistoryEventAddPhotos extends HistoryEvent {
  final List<String> photos;
  final bool needClearList;

  HistoryEventAddPhotos({
    required this.photos,
    this.needClearList = false,
  });
}
