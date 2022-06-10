import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment.dart';
import 'package:nossos_momentos/modules/add_moment/domain/entities/moment_type.dart';

class MomentModel extends Moment {
  MomentModel({
    required super.id,
    required super.dateTime,
    required super.title,
    required super.body,
    required super.type,
    required super.month,
    required super.monthDay,
    required super.year,
    required super.downloadUrlList,
  });

  static MomentModel fromJson(Map<String, dynamic> json) {
    return MomentModel(
      id: json['id'],
      dateTime: DateFormat().parse(json['dateTime']),
      title: json['title'],
      body: json['body'],
      type: MomentType.values.firstWhere((e) => e.value == json['type']),
      downloadUrlList: json['downloadUrlList'],
      year: json['year'],
      monthDay: json['monthDay'],
      month: json['month'],
    );
  }

  static List<MomentModel> fromListJson(dynamic result) {
    final List<MomentModel> momentsList = [];
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
      'year': year,
      'month': month,
      'monthDay': monthDay,
      'dateTime': DateFormat(DateFormat.YEAR_MONTH_DAY).format(dateTime),
      'type': type.value,
      'downloadUrlList' : downloadUrlList
    };
  }

  String toJson() => jsonEncode(toMap());

  Moment toEntity() {
    return Moment(
      id: id,
      dateTime: dateTime,
      title: title,
      body: body,
      type: type,
      year: year,
      monthDay: monthDay,
      month: month,
      downloadUrlList: downloadUrlList
    );
  }

  static MomentModel fromEntity(Moment moment) {
    return MomentModel(
      id: moment.id,
      dateTime: moment.dateTime,
      title: moment.title,
      body: moment.body,
      type: moment.type,
      downloadUrlList: moment.downloadUrlList,
      year: moment.year,
      month: moment.month,
      monthDay: moment.monthDay,
    );
  }
}
