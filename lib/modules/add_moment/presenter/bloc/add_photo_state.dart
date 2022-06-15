abstract class StoriesState {
  const StoriesState();
}

class HistoryStateInit extends StoriesState {
  const HistoryStateInit();
}

class HistoryStateShowGallery extends StoriesState {
  HistoryStateShowGallery();
}

class HistoryStateUpdateHistory extends StoriesState {
  final List<String> photos;

  const HistoryStateUpdateHistory({required this.photos});
}
