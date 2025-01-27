// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MomentModel _$MomentModelFromJson(Map<String, dynamic> json) => MomentModel(
      id: json['id'] as String,
      dateTime: MomentModel._fromJsonDate(json['dateTime'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      type: MomentModel._fromJsonType(json['type'] as String),
      month: json['month'] as String,
      monthDay: json['monthDay'] as String,
      year: json['year'] as String,
      downloadUrlList: (json['downloadUrlList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timelineId: json['time_line_id'] as String,
    );

Map<String, dynamic> _$MomentModelToJson(MomentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'year': instance.year,
      'month': instance.month,
      'monthDay': instance.monthDay,
      'downloadUrlList': instance.downloadUrlList,
      'dateTime': MomentModel._toJsonDate(instance.dateTime),
      'type': MomentModel._toJsonType(instance.type),
      'time_line_id': instance.timelineId,
    };
