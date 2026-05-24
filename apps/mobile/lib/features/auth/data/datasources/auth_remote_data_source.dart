import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/registro_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/token_pair_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/usuario_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegistroModel> registrar({
    required String nome,
    required String email,
    required String senha,
  });

  Future<TokenPairModel> login({
    required String email,
    required String senha,
  });

  Future<void> logout();

  Future<UsuarioModel> me();

  Future<void> verificarEmail({required String token});

  Future<void> reenviarVerificacao({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<RegistroModel> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'nome': nome, 'email': email, 'senha': senha},
    );
    return RegistroModel.fromJson(response.data!);
  }

  @override
  Future<TokenPairModel> login({
    required String email,
    required String senha,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'senha': senha},
    );
    return TokenPairModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  @override
  Future<UsuarioModel> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UsuarioModel.fromJson(response.data!);
  }

  @override
  Future<void> verificarEmail({required String token}) async {
    await _dio.post<void>('/auth/verify-email', data: {'token': token});
  }

  @override
  Future<void> reenviarVerificacao({required String email}) async {
    await _dio.post<void>(
      '/auth/resend-verification',
      data: {'email': email},
    );
  }
}

// Providers ----------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

/// Convenience: client generico autodispose, mantido aqui por compatibilidade
/// com codigo legado que possa estar lendo `apiClientProvider`.
final apiClientProvider = Provider.autoDispose<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
