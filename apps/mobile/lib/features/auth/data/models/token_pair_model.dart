import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_pair_model.freezed.dart';
part 'token_pair_model.g.dart';

/// Espelha o `TokenPairOutput` do backend Augustus.
@freezed
abstract class TokenPairModel with _$TokenPairModel {
  const factory TokenPairModel({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiraEm,
    required DateTime refreshTokenExpiraEm,
    required String tokenType,
  }) = _TokenPairModel;

  factory TokenPairModel.fromJson(Map<String, dynamic> json) =>
      _$TokenPairModelFromJson(json);
}
