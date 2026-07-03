// ignore_for_file: overridden_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/time_line.dart';

part 'time_line_model.g.dart';

@JsonSerializable()
class TimeLineModel extends TimeLine {
  TimeLineModel({
    required this.createdDate,
    required super.emails,
    required super.id,
    required super.owners,
    required this.momentIds,
    this.relationshipStartDate,
    this.relationshipEndDate,
    this.name = '',
    this.accentColor,
    this.isPremium = false,
    this.premiumUntil,
    this.coverPhotoUrl = '',
    this.nicknames = const {},
    this.enforceEndDate = false,
    this.roles = const {},
    this.momentEditPolicy = 'individual',
    this.pendingDeletion,
  }) : super(
          createdDate: createdDate,
          momentIds: momentIds,
          relationshipStartDate: relationshipStartDate,
          relationshipEndDate: relationshipEndDate,
          name: name,
          accentColor: accentColor,
          isPremium: isPremium,
          premiumUntil: premiumUntil,
          coverPhotoUrl: coverPhotoUrl,
          nicknames: nicknames,
          enforceEndDate: enforceEndDate,
          roles: roles,
          momentEditPolicy: momentEditPolicy,
          pendingDeletion: pendingDeletion,
        );

  @override
  @JsonKey(
      name: 'created_date',
      fromJson: _fromJsonTimeStamp,
      toJson: _toJsonTimeStamp)
  final Timestamp createdDate;

  @JsonKey(name: 'moment_ids')
  @override
  final List<String> momentIds;

  @JsonKey(name: 'relationship_start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime? relationshipStartDate;

  @JsonKey(name: 'relationship_end_date', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime? relationshipEndDate;

  @JsonKey(name: 'name', defaultValue: '')
  @override
  final String name;

  @JsonKey(name: 'accent_color')
  @override
  final int? accentColor;

  @JsonKey(name: 'is_premium', defaultValue: false)
  @override
  final bool isPremium;

  @JsonKey(name: 'premium_until', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime? premiumUntil;

  @JsonKey(name: 'cover_photo_url', defaultValue: '')
  @override
  final String coverPhotoUrl;

  @JsonKey(name: 'nicknames', defaultValue: <String, String>{})
  @override
  final Map<String, String> nicknames;

  @JsonKey(name: 'enforce_end_date', defaultValue: false)
  @override
  final bool enforceEndDate;

  @JsonKey(name: 'roles', defaultValue: <String, String>{})
  @override
  final Map<String, String> roles;

  @JsonKey(name: 'moment_edit_policy', defaultValue: 'individual')
  @override
  final String momentEditPolicy;

  @JsonKey(name: 'pending_deletion')
  @override
  final Map<String, bool>? pendingDeletion;

  static DateTime? _dateFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Object? _dateToJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);

  Map<String, dynamic> toJson() => _$TimeLineModelToJson(this);

  factory TimeLineModel.fromJson(Map<String, dynamic> json) =>
      _$TimeLineModelFromJson(json);

  static Timestamp _fromJsonTimeStamp(dynamic timestamp) {
    if(timestamp.runtimeType == Timestamp) {
      return timestamp;
    }

    if(timestamp.runtimeType == String) {
      final date = DateTime.parse(timestamp);
      return Timestamp.fromDate(date);
    }

    return timestamp;
  }

  static _toJsonTimeStamp(Timestamp timestamp) {
    return timestamp;
  }

  static TimeLineModel fromEntity(TimeLine timeLine) {
    return TimeLineModel(
      createdDate: timeLine.createdDate,
      emails: timeLine.emails,
      id: timeLine.id,
      momentIds: timeLine.momentIds,
      owners: timeLine.owners,
      relationshipStartDate: timeLine.relationshipStartDate,
      relationshipEndDate: timeLine.relationshipEndDate,
      name: timeLine.name,
      accentColor: timeLine.accentColor,
      isPremium: timeLine.isPremium,
      premiumUntil: timeLine.premiumUntil,
      coverPhotoUrl: timeLine.coverPhotoUrl,
      nicknames: timeLine.nicknames,
      enforceEndDate: timeLine.enforceEndDate,
      roles: timeLine.roles,
      momentEditPolicy: timeLine.momentEditPolicy,
      pendingDeletion: timeLine.pendingDeletion,
    );
  }
}
