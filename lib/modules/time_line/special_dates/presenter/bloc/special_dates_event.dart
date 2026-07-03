part of 'special_dates_bloc.dart';

abstract class SpecialDatesEvent {
  const SpecialDatesEvent();
}

class SpecialDatesStarted extends SpecialDatesEvent {
  final String timelineId;

  const SpecialDatesStarted({required this.timelineId});
}

class SpecialDatesUpdated extends SpecialDatesEvent {
  final List<SpecialDate> dates;

  const SpecialDatesUpdated(this.dates);
}

class SpecialDateAdded extends SpecialDatesEvent {
  final String title;
  final DateTime date;
  final int remindDaysBefore;

  const SpecialDateAdded({
    required this.title,
    required this.date,
    required this.remindDaysBefore,
  });
}

class SpecialDateRemoved extends SpecialDatesEvent {
  final String id;

  const SpecialDateRemoved(this.id);
}
