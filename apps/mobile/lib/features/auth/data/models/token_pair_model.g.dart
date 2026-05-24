// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_pair_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenPairModel _$TokenPairModelFromJson(
  Map<String, dynamic> json,
) => _TokenPairModel(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accessTokenExpiraEm: DateTime.parse(json['accessTokenExpiraEm'] as String),
  refreshTokenExpiraEm: DateTime.parse(json['refreshTokenExpiraEm'] as String),
  tokenType: json['tokenType'] as String,
);

Map<String, dynamic> _$TokenPairModelToJson(_TokenPairModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpiraEm': instance.accessTokenExpiraEm.toIso8601String(),
      'refreshTokenExpiraEm': instance.refreshTokenExpiraEm.toIso8601String(),
      'tokenType': instance.tokenType,
    };
