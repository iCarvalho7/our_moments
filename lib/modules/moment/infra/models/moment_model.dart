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
    this.isFavorite = false,
    this.locationName = '',
    this.latitude,
    this.longitude,
  }) : super(
          dateTime: dateTime,
          type: type,
          timelineId: timelineId,
          isFavorite: isFavorite,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
        );

  @override
  @JsonKey(fromJson: _fromJsonDate, toJson: _toJsonDate)
  final DateTime dateTime;

  @override
  @JsonKey(fromJson: _fromJsonType, toJson: _toJsonType)
  final MomentType type;

  @override
  @JsonKey(name: 'time_line_id')
  final String timelineId;

  @override
  @JsonKey(name: 'is_favorite', defaultValue: false)
  final bool isFavorite;

  @override
  @JsonKey(name: 'location_name', defaultValue: '')
  final String locationName;

  @override
  @JsonKey(fromJson: _doubleFromJson)
  final double? latitude;

  @override
  @JsonKey(fromJson: _doubleFromJson)
  final double? longitude;

  static double? _doubleFromJson(dynamic value) => (value as num?)?.toDouble();

  static _fromJsonDate(String dateTime) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).parse(dateTime);
  }

  static String _toJsonDate(DateTime time) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).format(time);
  }

  static MomentType _fromJsonType(String type) {
    final normalized = type.toLowerCase().trim();
    return MomentType.values.firstWhere(
      (e) => e.value.toLowerCase() == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MomentType.values.firstWhere(
        (e) =>
            e.value.toLowerCase().contains(normalized) ||
            normalized.contains(e.value.toLowerCase()),
        // Never throw on an unknown/legacy value — fall back to a safe default
        // so a single record can't break the whole moments query.
        orElse: () => MomentType.good,
      ),
    );
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
      timelineId: timelineId,
      isFavorite: isFavorite,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
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
      isFavorite: moment.isFavorite,
      locationName: moment.locationName,
      latitude: moment.latitude,
      longitude: moment.longitude,
    );
  }
}
