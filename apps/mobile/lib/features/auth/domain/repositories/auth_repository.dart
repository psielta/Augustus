import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/registro_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/token_pair_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  /// Cria conta. Backend devolve usuario em estado `PENDENTE_VERIFICACAO`
  /// e dispara email de verificacao; **nao** devolve tokens.
  Future<Either<Failure, RegistroModel>> registrar({
    required String nome,
    required String email,
    required String senha,
  });

  /// Login com email/senha. Falha com `EmailNaoVerificadoFailure` quando
  /// a conta ainda nao tem o email confirmado.
  Future<Either<Failure, TokenPairModel>> login({
    required String email,
    required String senha,
  });

  /// Revoga a sessao corrente no backend e limpa tokens locais.
  Future<Either<Failure, void>> logout();

  /// Verifica email via token recebido (POST /auth/verify-email).
  Future<Either<Failure, void>> verificarEmail({required String token});

  /// Reenvia email de verificacao. Backend respeita cooldown e nao vaza existencia.
  Future<Either<Failure, void>> reenviarVerificacao({required String email});

  /// Carrega o usuario corrente via GET /auth/me. Erros 401 sao tratados
  /// transparentemente pelo `RefreshInterceptor` (refresh single-flight).
  Future<Either<Failure, UsuarioEntity>> me();

  /// Tenta restaurar a sessao no bootstrap do app:
  ///   - se nao houver refresh em storage, devolve `Right(null)` (anonimo).
  ///   - se houver, tenta `/auth/me`. Caso o interceptor de refresh falhe,
  ///     o storage ja foi limpo e isto devolve `Left(RefreshTokenInvalidoFailure)`.
  Future<Either<Failure, UsuarioEntity?>> restaurarSessao();
}
