// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLineModel _$TimeLineModelFromJson(Map<String, dynamic> json) =>
    TimeLineModel(
      createdDate: TimeLineModel._fromJsonTimeStamp(json['created_date']),
      emails: (json['emails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      id: json['id'] as String,
      owner: json['owner'] as String,
      momentIds: (json['moment_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relationshipStartDate: TimeLineModel._dateFromJson(
        json['relationship_start_date'],
      ),
      name: json['name'] as String? ?? '',
      accentColor: (json['accent_color'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TimeLineModelToJson(TimeLineModel instance) =>
    <String, dynamic>{
      'emails': instance.emails,
      'id': instance.id,
      'owner': instance.owner,
      'created_date': TimeLineModel._toJsonTimeStamp(instance.createdDate),
      'moment_ids': instance.momentIds,
      'relationship_start_date': TimeLineModel._dateToJson(
        instance.relationshipStartDate,
      ),
      'name': instance.name,
      'accent_color': instance.accentColor,
    };
