// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_premium_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPremiumModel _$UserPremiumModelFromJson(Map<String, dynamic> json) =>
    UserPremiumModel(
      email: json['email'] as String? ?? '',
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: UserPremiumModel._dateFromJson(json['premium_until']),
    );

Map<String, dynamic> _$UserPremiumModelToJson(UserPremiumModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'is_premium': instance.isPremium,
      'premium_until': UserPremiumModel._dateToJson(instance.premiumUntil),
    };
