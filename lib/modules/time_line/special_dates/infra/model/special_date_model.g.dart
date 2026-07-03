// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecialDateModel _$SpecialDateModelFromJson(Map<String, dynamic> json) =>
    SpecialDateModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: SpecialDateModel._dateFromJson(json['date']),
      remindDaysBefore: (json['remind_days_before'] as num?)?.toInt() ?? 0,
      createdBy: json['created_by'] as String? ?? '',
    );

Map<String, dynamic> _$SpecialDateModelToJson(SpecialDateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'remind_days_before': instance.remindDaysBefore,
      'created_by': instance.createdBy,
      'date': SpecialDateModel._dateToJson(instance.date),
    };
