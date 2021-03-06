import 'dart:convert';

import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line_moment.dart';

class TimeLineMomentModel extends TimeLineMoment {
  TimeLineMomentModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.monthDay,
    required super.month,
  });

  static TimeLineMomentModel fromJson(Map<String, dynamic> json) {
    return TimeLineMomentModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: MomentType.values.firstWhere((e) => e.value == json['type']),
      month: json['month'],
      monthDay: json['monthDay'],
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
      'monthDay': monthDay,
      'month': month,
    };
  }

  String toJson() => jsonEncode(toMap());

  TimeLineMoment toEntity() {
    return TimeLineMoment(
      id: id,
      title: title,
      body: body,
      type: type,
      monthDay: monthDay,
      month: month,
    );
  }
}
