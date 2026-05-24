import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/auth_token_storage.dart';

/// Lista de endpoints publicos do backend Augustus que **nao** devem receber
/// `Authorization: Bearer`.
const _publicAuthPaths = <String>{
  '/auth/login',
  '/auth/register',
  '/auth/refresh',
  '/auth/verify-email',
  '/auth/resend-verification',
};

bool _isPublicAuthPath(String path) {
  return _publicAuthPaths.any(path.contains);
}

/// Injeta `Authorization: Bearer <accessToken>` em toda request, exceto
/// para endpoints publicos de auth. Le do storage de forma assincrona.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AuthTokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  final AuthTokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicAuthPath(options.path)) {
      return handler.next(options);
    }
    final token = await _tokenStorage.readAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
