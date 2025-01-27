// ignore_for_file: overridden_fields

import 'package:intl/intl.dart';

import '../../domain/entities/moment.dart';
import '../../domain/entities/moment_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'moment_model.g.dart';

@JsonSerializable()
class MomentModel extends Moment {

  MomentModel({
    required super.id,
    required this.dateTime,
    required super.title,
    required super.body,
    required this.type,
    required super.month,
    required super.monthDay,
    required super.year,
    required super.downloadUrlList,
    required this.timelineId,
  }) : super(dateTime: dateTime, type: type, timelineId: timelineId);

  @override
  @JsonKey(fromJson: _fromJsonDate, toJson: _toJsonDate)
  final DateTime dateTime;

  @override
  @JsonKey(fromJson: _fromJsonType, toJson: _toJsonType)
  final MomentType type;

  @override
  @JsonKey(name: 'time_line_id')
  final String timelineId;

  static _fromJsonDate(String dateTime) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).parse(dateTime);
  }

  static String _toJsonDate(DateTime time) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).format(time);
  }

  static MomentType _fromJsonType(String type) {
    return MomentType.values.firstWhere((e) => e.value.contains(type));
  }

  static String _toJsonType(MomentType type) => type.value;

  factory MomentModel.fromJson(Map<String, dynamic> json) => _$MomentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MomentModelToJson(this);

  Moment toEntity() {
    return Moment(
      id: id,
      dateTime: dateTime,
      title: title,
      body: body,
      type: type,
      year: year,
      monthDay: monthDay,
      month: month,
      downloadUrlList: downloadUrlList,
      timelineId: timelineId
    );
  }

  static MomentModel fromEntity(Moment moment) {
    return MomentModel(
      id: moment.id,
      dateTime: moment.dateTime,
      title: moment.title,
      body: moment.body,
      type: moment.type,
      downloadUrlList: moment.downloadUrlList,
      year: moment.year,
      month: moment.month,
      monthDay: moment.monthDay,
      timelineId: moment.timelineId,
    );
  }
}
