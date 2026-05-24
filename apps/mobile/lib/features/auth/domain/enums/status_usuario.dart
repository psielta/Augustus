import 'package:json_annotation/json_annotation.dart';

enum StatusUsuario {
  @JsonValue('ATIVO')
  ativo,
  @JsonValue('PENDENTE_VERIFICACAO')
  pendenteVerificacao,
  @JsonValue('BLOQUEADO')
  bloqueado,
  @JsonValue('DESATIVADO')
  desativado,
}
