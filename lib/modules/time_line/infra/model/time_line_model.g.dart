// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLineModel _$TimeLineModelFromJson(Map<String, dynamic> json) =>
    TimeLineModel(
      createdDate: TimeLineModel._fromJsonTimeStamp(json['created_date']),
      emails:
          (json['emails'] as List<dynamic>).map((e) => e as String).toList(),
      id: json['id'] as String,
      momentIds: (json['moment_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TimeLineModelToJson(TimeLineModel instance) =>
    <String, dynamic>{
      'emails': instance.emails,
      'id': instance.id,
      'created_date': TimeLineModel._toJsonTimeStamp(instance.createdDate),
      'moment_ids': instance.momentIds,
    };
