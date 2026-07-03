// ignore_for_file: overridden_fields, invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/special_date.dart';

part 'special_date_model.g.dart';

@JsonSerializable()
class SpecialDateModel extends SpecialDate {
  const SpecialDateModel({
    @JsonKey(name: 'id', defaultValue: '') required super.id,
    @JsonKey(name: 'title', defaultValue: '') required super.title,
    required this.date,
    @JsonKey(name: 'remind_days_before', defaultValue: 0)
    required super.remindDaysBefore,
    @JsonKey(name: 'created_by', defaultValue: '') required super.createdBy,
  }) : super(date: date);

  @JsonKey(name: 'date', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime date;

  static DateTime _dateFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Object? _dateToJson(DateTime date) => Timestamp.fromDate(date);

  /// The document id is the Firestore key (kept out of the stored map).
  Map<String, dynamic> toJson() => _$SpecialDateModelToJson(this)..remove('id');

  factory SpecialDateModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialDateModelFromJson(json);

  factory SpecialDateModel.fromFirestore(String id, Map<String, dynamic> data) =>
      SpecialDateModel.fromJson({...data, 'id': id});

  SpecialDate toEntity() => SpecialDate(
        id: id,
        title: title,
        date: date,
        remindDaysBefore: remindDaysBefore,
        createdBy: createdBy,
      );
}
