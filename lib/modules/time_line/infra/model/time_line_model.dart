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
    required this.momentIds,
  }) : super(createdDate: createdDate, momentIds: momentIds);

  @override
  @JsonKey(name: 'created_date', fromJson: _fromJsonTimeStamp, toJson: _toJsonTimeStamp)
  final Timestamp createdDate;

  @JsonKey(name: 'moment_ids')
  @override
  final List<String> momentIds;

  Map<String, dynamic> toJson() => _$TimeLineModelToJson(this);

  factory TimeLineModel.fromJson(Map<String, dynamic> json) => _$TimeLineModelFromJson(json);

  static _fromJsonTimeStamp(Timestamp timestamp) {
    return timestamp;
  }

  static _toJsonTimeStamp(Timestamp timestamp) {
    return timestamp.toDate().toIso8601String();
  }
}
