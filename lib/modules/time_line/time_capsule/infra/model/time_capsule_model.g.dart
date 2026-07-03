// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_capsule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeCapsuleModel _$TimeCapsuleModelFromJson(Map<String, dynamic> json) =>
    TimeCapsuleModel(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      revealDate: TimeCapsuleModel._dateFromJson(json['reveal_date']),
      fromEmail: json['from_email'] as String? ?? '',
      toEmail: json['to_email'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      revealed: json['revealed'] as bool? ?? false,
    );

Map<String, dynamic> _$TimeCapsuleModelToJson(TimeCapsuleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'media_url': instance.mediaUrl,
      'from_email': instance.fromEmail,
      'to_email': instance.toEmail,
      'revealed': instance.revealed,
      'reveal_date': TimeCapsuleModel._dateToJson(instance.revealDate),
    };
