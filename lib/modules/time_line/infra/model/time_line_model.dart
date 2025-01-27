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
  @JsonKey(
      name: 'created_date',
      fromJson: _fromJsonTimeStamp,
      toJson: _toJsonTimeStamp)
  final Timestamp createdDate;

  @JsonKey(name: 'moment_ids')
  @override
  final List<String> momentIds;

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
    );
  }
}
