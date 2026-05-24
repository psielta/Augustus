import 'package:json_annotation/json_annotation.dart';

enum PapelSistema {
  @JsonValue('USUARIO')
  usuario,
  @JsonValue('ADMIN')
  admin,
}
