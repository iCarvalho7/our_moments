part of 'add_date_bloc.dart';

abstract class AddDateEvent {
  const AddDateEvent();
}

class AddDateEventAddDateToLabel extends AddDateEvent {
  final String dateLabel;

  const AddDateEventAddDateToLabel({required this.dateLabel});
}
