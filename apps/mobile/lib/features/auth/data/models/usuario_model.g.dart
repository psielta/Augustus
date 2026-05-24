// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UsuarioModel _$UsuarioModelFromJson(Map<String, dynamic> json) =>
    _UsuarioModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      status: $enumDecode(_$StatusUsuarioEnumMap, json['status']),
      papelSistema: $enumDecode(_$PapelSistemaEnumMap, json['papelSistema']),
      emailVerificado: json['emailVerificado'] as bool,
      criadoEm: json['criadoEm'] == null
          ? null
          : DateTime.parse(json['criadoEm'] as String),
    );

Map<String, dynamic> _$UsuarioModelToJson(_UsuarioModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'status': _$StatusUsuarioEnumMap[instance.status]!,
      'papelSistema': _$PapelSistemaEnumMap[instance.papelSistema]!,
      'emailVerificado': instance.emailVerificado,
      'criadoEm': instance.criadoEm?.toIso8601String(),
    };

const _$StatusUsuarioEnumMap = {
  StatusUsuario.ativo: 'ATIVO',
  StatusUsuario.pendenteVerificacao: 'PENDENTE_VERIFICACAO',
  StatusUsuario.bloqueado: 'BLOQUEADO',
  StatusUsuario.desativado: 'DESATIVADO',
};

const _$PapelSistemaEnumMap = {
  PapelSistema.usuario: 'USUARIO',
  PapelSistema.admin: 'ADMIN',
};
