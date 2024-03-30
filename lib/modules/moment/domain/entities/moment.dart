import 'package:nossos_momentos/modules/core/utils/date_util.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
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
  final String timelineId;

  const Moment(
      {required this.id,
      required this.dateTime,
      required this.title,
      required this.body,
      required this.type,
      required this.monthDay,
      required this.month,
      required this.year,
      required this.downloadUrlList,
      required this.timelineId,
      this.isEditing = false});

  Moment copyWith({
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
    String? timelineId,
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
      timelineId: timelineId ?? this.timelineId,
    );
  }

  static Moment empty(String timelineId) {
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
      timelineId: timelineId,
    );
  }

  String get dateTimeFormatted =>
      "$monthDay\n${month.substring(0, 3).replaceFirst(month[0], month[0].toUpperCase())}";

  List<String> get localImgList => downloadUrlList.where((e) => !e.isHttpUrl).toList();

  List<String> get uploadedImgList => downloadUrlList.where((e) => e.isHttpUrl).toList();

  bool get isAllFieldsFilled =>
      dateTime != AddOrEditMomentBloc.defaultDateTime &&
      title.isNotEmpty &&
      body.isNotEmpty;

  String get dateTimeComplete => dateTime != AddOrEditMomentBloc.defaultDateTime
      ? DateUtil.getFormattedDate(dateTime)
      : DateTimeSection.addDate;
}
