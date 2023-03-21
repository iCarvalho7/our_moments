import 'package:nossos_momentos/modules/core/utils/date_util.dart';
import 'package:nossos_momentos/modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/moment/presenter/widget/date_time_section.dart';
import 'package:uuid/uuid.dart';

import 'moment_type.dart';

class Moment {
  final String id;
  final DateTime dateTime;
  final String title;
  final String body;
  final String year;
  final String month;
  final String monthDay;
  final MomentType type;
  final List<String> downloadUrlList;
  final bool isEditing;

  const Moment({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.body,
    required this.type,
    required this.monthDay,
    required this.month,
    required this.year,
    required this.downloadUrlList,
    this.isEditing = false
  });

  Moment clone({
    String? id,
    DateTime? dateTime,
    String? title,
    String? body,
    String? year,
    String? month,
    String? monthDay,
    MomentType? type,
    List<String>? downloadUrlList,
    bool? isEditing,
  }) {
    return Moment(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      monthDay: monthDay ?? this.monthDay,
      month: month ?? this.month,
      year: year ?? this.year,
      downloadUrlList: downloadUrlList ?? this.downloadUrlList,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  static Moment empty() {
    return Moment(
      id: const Uuid().v1(),
      dateTime: AddOrEditMomentBloc.defaultDateTime,
      title: '',
      body: '',
      type: MomentType.bad,
      monthDay: '',
      month: '',
      year: '',
      downloadUrlList: [],
    );
  }

  String get dateTimeFormatted =>
      monthDay +
          "\n" +
          month.substring(0, 3).replaceFirst(month[0], month[0].toUpperCase());

  String get dateTimeComplete => dateTime != AddOrEditMomentBloc.defaultDateTime
      ? DateUtil.getFormattedDate(dateTime)
      : DateTimeSection.addDate;
}
