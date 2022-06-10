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

  HistoryEventAddPhotos({
    required this.photos,
  });
}
