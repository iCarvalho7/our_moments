import 'dart:convert';

import 'package:nossos_momentos/modules/time_line/domain/entities/moment.dart';

class MomentModel extends Moment {
  MomentModel({
    required super.id,
    required super.dateTime,
    required super.title,
    required super.body,
    required super.type,
  });

  static MomentModel fromJson(Map<String, dynamic> json) {
    return MomentModel(
      id: json['id'],
      dateTime: json['dateTime'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
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
      'dateTime': dateTime,
      'type': type,
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
    );
  }
}
