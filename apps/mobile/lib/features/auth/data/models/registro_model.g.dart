// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegistroModel _$RegistroModelFromJson(Map<String, dynamic> json) =>
    _RegistroModel(
      usuario: UsuarioModel.fromJson(json['usuario'] as Map<String, dynamic>),
      mensagem: json['mensagem'] as String,
    );

Map<String, dynamic> _$RegistroModelToJson(_RegistroModel instance) =>
    <String, dynamic>{
      'usuario': instance.usuario,
      'mensagem': instance.mensagem,
    };
