import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/enums/papel_sistema.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/enums/status_usuario.dart';

/// Espelha o `UsuarioOutput` do backend Augustus, sem detalhes de transporte.
class UsuarioEntity extends Equatable {
  final String id;
  final String nome;
  final String email;
  final StatusUsuario status;
  final PapelSistema papelSistema;
  final bool emailVerificado;
  final DateTime? criadoEm;

  const UsuarioEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.status,
    required this.papelSistema,
    required this.emailVerificado,
    this.criadoEm,
  });

  UsuarioEntity copyWith({
    String? id,
    String? nome,
    String? email,
    StatusUsuario? status,
    PapelSistema? papelSistema,
    bool? emailVerificado,
    DateTime? criadoEm,
  }) {
    return UsuarioEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      status: status ?? this.status,
      papelSistema: papelSistema ?? this.papelSistema,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        status,
        papelSistema,
        emailVerificado,
        criadoEm,
      ];
}
