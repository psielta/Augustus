import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/auth_token_storage.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/problem_detail.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/registro_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/token_pair_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthTokenStorage tokenStorage,
  })  : _remote = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remote;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<Either<Failure, RegistroModel>> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final data = await _remote.registrar(nome: nome, email: email, senha: senha);
      return Right(data);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TokenPairModel>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final tokens = await _remote.login(email: email, senha: senha);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessTokenExpiraEm: tokens.accessTokenExpiraEm,
        refreshTokenExpiraEm: tokens.refreshTokenExpiraEm,
      );
      return Right(tokens);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    Failure? remoteFailure;
    try {
      await _remote.logout();
    } on DioException catch (e) {
      remoteFailure = _failureFromDio(e);
    } catch (_) {
      // Ignora — sempre limpamos o storage local.
    }
    // Logout local incondicional: mesmo se o backend falhou, o usuario
    // pediu para sair.
    await _tokenStorage.clear();
    if (remoteFailure != null && remoteFailure is! UnauthorizedFailure) {
      // 401 no logout e tratado como sucesso (a sessao ja era invalida).
      return Left(remoteFailure);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, UsuarioEntity>> me() async {
    try {
      final model = await _remote.me();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verificarEmail({required String token}) async {
    try {
      await _remote.verificarEmail(token: token);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reenviarVerificacao({required String email}) async {
    try {
      await _remote.reenviarVerificacao(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UsuarioEntity?>> restaurarSessao() async {
    final temRefresh = await _tokenStorage.hasRefresh();
    if (!temRefresh) {
      return const Right(null);
    }
    // Tenta /auth/me. Se o access estiver expirado, RefreshInterceptor
    // tenta refresh transparente; se o refresh falhar, ele ja limpou o
    // storage e o retorno aqui sera 401.
    try {
      final model = await _remote.me();
      return Right(model.toEntity());
    } on DioException catch (e) {
      final failure = _failureFromDio(e);
      // Sessao perdida: storage ja foi limpo pelo interceptor.
      if (failure is UnauthorizedFailure ||
          failure is RefreshTokenInvalidoFailure) {
        return Right(null);
      }
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Failure _failureFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      try {
        return ProblemDetail.fromJson(data).toFailure();
      } catch (_) {
        // Ignora e cai no fallback.
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Requisicao cancelada');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.unknown:
        if (e.error is Object &&
            e.error.toString().contains('SocketException')) {
          return const NetworkFailure();
        }
        return ServerFailure(
          message: 'Erro no servidor',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
        return const ServerFailure(message: 'Certificado invalido');
      case DioExceptionType.badResponse:
        return ServerFailure(
          message: 'Erro no servidor',
          statusCode: e.response?.statusCode,
        );
    }
  }
}

// Provider -----------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
  );
});
