import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/enums/papel_sistema.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/enums/status_usuario.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'usuario_model.freezed.dart';
part 'usuario_model.g.dart';

/// Espelha o `UsuarioOutput` do backend Augustus (camelCase no JSON).
@freezed
abstract class UsuarioModel with _$UsuarioModel {
  const UsuarioModel._();

  const factory UsuarioModel({
    required String id,
    required String nome,
    required String email,
    required StatusUsuario status,
    required PapelSistema papelSistema,
    required bool emailVerificado,
    DateTime? criadoEm,
  }) = _UsuarioModel;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) =>
      _$UsuarioModelFromJson(json);

  UsuarioEntity toEntity() => UsuarioEntity(
        id: id,
        nome: nome,
        email: email,
        status: status,
        papelSistema: papelSistema,
        emailVerificado: emailVerificado,
        criadoEm: criadoEm,
      );
}
