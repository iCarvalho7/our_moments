// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLineModel _$TimeLineModelFromJson(
  Map<String, dynamic> json,
) => TimeLineModel(
  createdDate: TimeLineModel._fromJsonTimeStamp(json['created_date']),
  emails: (json['emails'] as List<dynamic>).map((e) => e as String).toList(),
  id: json['id'] as String,
  owners: (json['owners'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  momentIds: (json['moment_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  relationshipStartDate: TimeLineModel._dateFromJson(
    json['relationship_start_date'],
  ),
  relationshipEndDate: TimeLineModel._dateFromJson(
    json['relationship_end_date'],
  ),
  name: json['name'] as String? ?? '',
  accentColor: (json['accent_color'] as num?)?.toInt(),
  isPremium: json['is_premium'] as bool? ?? false,
  premiumUntil: TimeLineModel._dateFromJson(json['premium_until']),
  coverPhotoUrl: json['cover_photo_url'] as String? ?? '',
  nicknames:
      (json['nicknames'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  enforceEndDate: json['enforce_end_date'] as bool? ?? false,
  roles:
      (json['roles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  momentEditPolicy: json['moment_edit_policy'] as String? ?? 'individual',
  pendingDeletion: (json['pending_deletion'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as bool),
  ),
);

Map<String, dynamic> _$TimeLineModelToJson(TimeLineModel instance) =>
    <String, dynamic>{
      'emails': instance.emails,
      'id': instance.id,
      'owners': instance.owners,
      'created_date': TimeLineModel._toJsonTimeStamp(instance.createdDate),
      'moment_ids': instance.momentIds,
      'relationship_start_date': TimeLineModel._dateToJson(
        instance.relationshipStartDate,
      ),
      'relationship_end_date': TimeLineModel._dateToJson(
        instance.relationshipEndDate,
      ),
      'name': instance.name,
      'accent_color': instance.accentColor,
      'is_premium': instance.isPremium,
      'premium_until': TimeLineModel._dateToJson(instance.premiumUntil),
      'cover_photo_url': instance.coverPhotoUrl,
      'nicknames': instance.nicknames,
      'enforce_end_date': instance.enforceEndDate,
      'roles': instance.roles,
      'moment_edit_policy': instance.momentEditPolicy,
      'pending_deletion': instance.pendingDeletion,
    };
