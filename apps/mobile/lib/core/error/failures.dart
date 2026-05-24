import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ---------- Network ----------
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sem conexao com a internet',
    super.statusCode,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Erro no servidor',
    super.statusCode,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Tempo de conexao esgotado',
    super.statusCode,
  });
}

// ---------- Data ----------
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erro no armazenamento local',
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Dados invalidos',
    super.statusCode,
  });
}

// ---------- Auth genericas ----------
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Falha de autenticacao',
    super.statusCode,
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Acesso nao autorizado',
    super.statusCode,
  });
}

class InputFailure extends Failure {
  const InputFailure({
    super.message = 'Entrada invalida',
    super.statusCode,
  });
}

// ---------- Auth Augustus (mapeadas a partir do ProblemDetail.type) ----------
class EmailJaCadastradoFailure extends Failure {
  const EmailJaCadastradoFailure({
    super.message = 'Email ja cadastrado',
    super.statusCode = 409,
  });
}

class EmailNaoVerificadoFailure extends Failure {
  const EmailNaoVerificadoFailure({
    super.message = 'Email nao verificado',
    super.statusCode = 403,
  });
}

class CredenciaisInvalidasFailure extends Failure {
  const CredenciaisInvalidasFailure({
    super.message = 'Email ou senha invalidos',
    super.statusCode = 401,
  });
}

class UsuarioBloqueadoFailure extends Failure {
  const UsuarioBloqueadoFailure({
    super.message =
        'Conta bloqueada temporariamente apos varias tentativas. Aguarde alguns minutos.',
    super.statusCode = 423,
  });
}

class RefreshTokenInvalidoFailure extends Failure {
  const RefreshTokenInvalidoFailure({
    super.message = 'Sessao expirada. Faca login novamente.',
    super.statusCode = 401,
  });
}

class TokenVerificacaoInvalidoFailure extends Failure {
  const TokenVerificacaoInvalidoFailure({
    super.message = 'Token invalido, expirado ou ja utilizado',
    super.statusCode = 400,
  });
}

class EnvioEmailFalhouFailure extends Failure {
  const EnvioEmailFalhouFailure({
    super.message =
        'Nao foi possivel enviar o email agora. Tente novamente em alguns minutos.',
    super.statusCode = 502,
  });
}
