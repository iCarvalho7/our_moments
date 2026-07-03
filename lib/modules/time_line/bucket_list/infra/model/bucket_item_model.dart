// ignore_for_file: overridden_fields, invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/bucket_item.dart';

part 'bucket_item_model.g.dart';

@JsonSerializable()
class BucketItemModel extends BucketItem {
  const BucketItemModel({
    @JsonKey(name: 'id', defaultValue: '') required super.id,
    @JsonKey(name: 'title', defaultValue: '') required super.title,
    @JsonKey(name: 'done', defaultValue: false) required super.done,
    required this.createdAt,
    @JsonKey(name: 'category') super.category,
    @JsonKey(name: 'notes') super.notes,
  }) : super(createdAt: createdAt);

  @JsonKey(name: 'created_at', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime createdAt;

  static DateTime _dateFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Object? _dateToJson(DateTime date) => Timestamp.fromDate(date);

  /// The document id is the Firestore key (kept out of the stored map).
  Map<String, dynamic> toJson() => _$BucketItemModelToJson(this)..remove('id');

  factory BucketItemModel.fromJson(Map<String, dynamic> json) =>
      _$BucketItemModelFromJson(json);

  factory BucketItemModel.fromFirestore(String id, Map<String, dynamic> data) =>
      BucketItemModel.fromJson({...data, 'id': id});

  BucketItem toEntity() => BucketItem(
        id: id,
        title: title,
        done: done,
        createdAt: createdAt,
        category: category,
        notes: notes,
      );
}
