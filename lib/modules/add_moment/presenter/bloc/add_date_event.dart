abstract class AddDateEvent {
  const AddDateEvent();
}

class AddDateEventAddDateToLabel extends AddDateEvent {
  final String dateLabel;

  const AddDateEventAddDateToLabel({required this.dateLabel});
}
