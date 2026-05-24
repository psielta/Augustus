import 'package:json_annotation/json_annotation.dart';

enum TipoToken {
  @JsonValue('VERIFICACAO_EMAIL')
  verificacaoEmail,
  @JsonValue('RESET_SENHA')
  resetSenha,
  @JsonValue('ALTERACAO_EMAIL')
  alteracaoEmail,
}
