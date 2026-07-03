// ignore_for_file: overridden_fields, invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entity/user_premium.dart';

part 'user_premium_model.g.dart';

/// Firestore <-> [UserPremium] mapping for `users/{uid}`.
///
/// The [uid] is the Firestore doc id (not a field of the doc), so it is kept
/// out of the generated (de)serialization (`includeFromJson/ToJson: false`) and
/// supplied from the data source when reading / used directly when writing.
@JsonSerializable()
class UserPremiumModel extends UserPremium {
  UserPremiumModel({
    // Doc id, never (de)serialized — supplied from outside the JSON.
    @JsonKey(includeFromJson: false, includeToJson: false) super.uid = '',
    this.email = '',
    this.isPremium = false,
    this.premiumUntil,
  }) : super(
          email: email,
          isPremium: isPremium,
          premiumUntil: premiumUntil,
        );

  @JsonKey(name: 'email', defaultValue: '')
  @override
  final String email;

  @JsonKey(name: 'is_premium', defaultValue: false)
  @override
  final bool isPremium;

  @JsonKey(name: 'premium_until', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime? premiumUntil;

  static DateTime? _dateFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Object? _dateToJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);

  Map<String, dynamic> toJson() => _$UserPremiumModelToJson(this);

  /// Builds the model from a Firestore doc, injecting the [uid] (doc id), which
  /// is not part of the stored JSON.
  factory UserPremiumModel.fromJson(Map<String, dynamic> json, {String uid = ''}) {
    final model = _$UserPremiumModelFromJson(json);
    return UserPremiumModel(
      uid: uid,
      email: model.email,
      isPremium: model.isPremium,
      premiumUntil: model.premiumUntil,
    );
  }

  static UserPremiumModel fromEntity(UserPremium user) {
    return UserPremiumModel(
      uid: user.uid,
      email: user.email,
      isPremium: user.isPremium,
      premiumUntil: user.premiumUntil,
    );
  }
}
