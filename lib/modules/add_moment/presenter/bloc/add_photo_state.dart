abstract class HistoryState {
  const HistoryState();
}

class HistoryStateInit extends HistoryState {
  const HistoryStateInit();
}

class HistoryStateShowGallery extends HistoryState {
  HistoryStateShowGallery();
}

class HistoryStateUpdateHistory extends HistoryState {
  final List<String> photos;

  const HistoryStateUpdateHistory({required this.photos});
}
