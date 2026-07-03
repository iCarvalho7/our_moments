class SpecialDate {
  final String id;
  final String title;
  final DateTime date;

  /// How many days before [date] the reminder should fire.
  final int remindDaysBefore;

  /// Email of the member who created this special date.
  final String createdBy;

  const SpecialDate({
    required this.id,
    required this.title,
    required this.date,
    required this.remindDaysBefore,
    required this.createdBy,
  });
}
