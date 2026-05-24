import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/usuario_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registro_model.freezed.dart';
part 'registro_model.g.dart';

/// Espelha o `RegistroOutput` do backend Augustus. Note que registro **nao**
/// devolve tokens — o usuario precisa verificar o email antes de poder logar.
@freezed
abstract class RegistroModel with _$RegistroModel {
  const factory RegistroModel({
    required UsuarioModel usuario,
    required String mensagem,
  }) = _RegistroModel;

  factory RegistroModel.fromJson(Map<String, dynamic> json) =>
      _$RegistroModelFromJson(json);
}
