// ignore_for_file: overridden_fields, invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/time_capsule.dart';

part 'time_capsule_model.g.dart';

@JsonSerializable()
class TimeCapsuleModel extends TimeCapsule {
  const TimeCapsuleModel({
    @JsonKey(name: 'id', defaultValue: '') required super.id,
    @JsonKey(name: 'message', defaultValue: '') required super.message,
    required this.revealDate,
    @JsonKey(name: 'from_email', defaultValue: '') required super.fromEmail,
    @JsonKey(name: 'to_email', defaultValue: '') required super.toEmail,
    @JsonKey(name: 'media_url', defaultValue: '') super.mediaUrl,
    @JsonKey(name: 'revealed', defaultValue: false) super.revealed,
  }) : super(revealDate: revealDate);

  @JsonKey(name: 'reveal_date', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime revealDate;

  static DateTime _dateFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Object? _dateToJson(DateTime date) => Timestamp.fromDate(date);

  /// The document id is the Firestore key (kept out of the stored map).
  Map<String, dynamic> toJson() => _$TimeCapsuleModelToJson(this)..remove('id');

  factory TimeCapsuleModel.fromJson(Map<String, dynamic> json) =>
      _$TimeCapsuleModelFromJson(json);

  factory TimeCapsuleModel.fromFirestore(String id, Map<String, dynamic> data) =>
      TimeCapsuleModel.fromJson({...data, 'id': id});

  TimeCapsule toEntity() => TimeCapsule(
        id: id,
        message: message,
        mediaUrl: mediaUrl,
        revealDate: revealDate,
        fromEmail: fromEmail,
        toEmail: toEmail,
        revealed: revealed,
      );
}
