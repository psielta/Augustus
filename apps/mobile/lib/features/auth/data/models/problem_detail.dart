import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';

/// Representa um body RFC 7807 retornado pelo backend Augustus.
///
/// Nao usa Freezed para evitar codegen num modelo trivial. Tambem nao
/// implementa Equatable porque o ProblemDetail nao precisa ser comparado.
class ProblemDetail {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;

  const ProblemDetail({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
  });

  factory ProblemDetail.fromJson(Map<String, dynamic> json) {
    return ProblemDetail(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
    );
  }

  /// Slug terminal do `type` URI (ex.: `https://.../errors/email-ja-cadastrado` -> `email-ja-cadastrado`).
  String? get slug {
    if (type == null) return null;
    final pieces = type!.split('/');
    if (pieces.isEmpty) return null;
    return pieces.last;
  }

  /// Mapeia o ProblemDetail para uma `Failure` especifica do dominio Augustus,
  /// caindo em fallbacks por status code quando o slug nao e reconhecido.
  Failure toFailure() {
    switch (slug) {
      case 'email-ja-cadastrado':
        return EmailJaCadastradoFailure(message: detail ?? 'Email ja cadastrado');
      case 'email-nao-verificado':
        return EmailNaoVerificadoFailure(message: detail ?? 'Email nao verificado');
      case 'credenciais-invalidas':
        return CredenciaisInvalidasFailure(
          message: detail ?? 'Email ou senha invalidos',
        );
      case 'usuario-bloqueado':
        return UsuarioBloqueadoFailure(message: detail ?? 'Usuario bloqueado');
      case 'refresh-token-invalido':
        return RefreshTokenInvalidoFailure(
          message: detail ?? 'Sessao expirada. Faca login novamente.',
        );
      case 'token-verificacao-invalido':
        return TokenVerificacaoInvalidoFailure(
          message: detail ?? 'Token invalido, expirado ou ja utilizado',
        );
      case 'nao-autenticado':
        return UnauthorizedFailure(
          message: detail ?? 'Autenticacao obrigatoria',
          statusCode: status,
        );
      case 'envio-email-falhou':
        return EnvioEmailFalhouFailure(
          message: detail ?? 'Falha no envio de email',
        );
    }

    switch (status) {
      case 400:
        return ValidationFailure(message: detail ?? 'Dados invalidos');
      case 401:
        return UnauthorizedFailure(
          message: detail ?? 'Nao autorizado',
          statusCode: 401,
        );
      case 403:
        return AuthFailure(message: detail ?? 'Acesso negado', statusCode: 403);
      case 409:
        return ServerFailure(message: detail ?? 'Conflito', statusCode: 409);
      case 423:
        return UsuarioBloqueadoFailure(
          message: detail ?? 'Recurso bloqueado',
        );
      default:
        return ServerFailure(
          message: detail ?? title ?? 'Erro no servidor',
          statusCode: status,
        );
    }
  }
}
