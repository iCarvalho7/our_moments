import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

class TimeLineMomentModel extends TimeLineMoment {
  TimeLineMomentModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.dateTime,
  });

  static TimeLineMomentModel fromJson(Map<String, dynamic> json) {
    final newDate =
        DateFormat(DateFormat.YEAR_MONTH_DAY).parse(json['dateTime']);
    final String date =
        "${newDate.day}\n" + DateFormat(DateFormat.ABBR_MONTH).format(newDate);
    return TimeLineMomentModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: MomentType.values.firstWhere((e) => e.value == json['type']),
      dateTime: date,
    );
  }

  static List<TimeLineMomentModel> fromListJson(dynamic result) {
    final List<TimeLineMomentModel> momentsList = [];
    result.map(
      (key, value) => momentsList.add(
        fromJson(value),
      ),
    );
    return momentsList;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
    };
  }

  String toJson() => jsonEncode(toMap());

  TimeLineMoment toEntity() {
    return TimeLineMoment(
      id: id,
      title: title,
      body: body,
      type: type,
      dateTime: dateTime,
    );
  }
}
