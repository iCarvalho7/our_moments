// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BucketItemModel _$BucketItemModelFromJson(Map<String, dynamic> json) =>
    BucketItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      createdAt: BucketItemModel._dateFromJson(json['created_at']),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BucketItemModelToJson(BucketItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'done': instance.done,
      'category': instance.category,
      'notes': instance.notes,
      'created_at': BucketItemModel._dateToJson(instance.createdAt),
    };
