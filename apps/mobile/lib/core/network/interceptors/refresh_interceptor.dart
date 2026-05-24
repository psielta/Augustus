import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/auth_token_storage.dart';

/// Lista de endpoints publicos do backend Augustus que nao devem disparar
/// refresh em 401 (especialmente o proprio `/auth/refresh`, para evitar loop).
const _skipPaths = <String>{
  '/auth/login',
  '/auth/register',
  '/auth/refresh',
  '/auth/verify-email',
  '/auth/resend-verification',
};

bool _isSkipPath(String path) {
  return _skipPaths.any(path.contains);
}

/// Marca usada nos headers da request retentada apos refresh, para evitar
/// que uma segunda 401 dispare outro refresh em cascata.
const _retryHeader = 'X-Augustus-Auth-Retry';

/// Retenta a request original com novo token, sem passar pelo refresh
/// novamente. Tipo `RetryRequest = Future<Response> Function(RequestOptions)`.
typedef RetryRequest = Future<Response<dynamic>> Function(RequestOptions);

/// Trata 401 com refresh single-flight + token-staleness check, sem depender
/// de `authProvider`, `authRepositoryProvider` ou qualquer provider de UI.
///
/// Como `QueuedInterceptor` serializa `onError` automaticamente, varios
/// requests recebendo 401 em paralelo so disparam **um** refresh por vez.
/// Antes de chamar `/auth/refresh`, comparamos o Bearer da request original
/// com o token atual em storage: se outro refresh ja trocou o token, apenas
/// retentamos com o atual, evitando refresh redundante (que poderia falhar
/// porque o backend rotaciona o refresh token).
class RefreshInterceptor extends QueuedInterceptor {
  RefreshInterceptor({
    required Dio refreshDio,
    required AuthTokenStorage tokenStorage,
    required RetryRequest retry,
  })  : _refreshDio = refreshDio,
        _tokenStorage = tokenStorage,
        _retry = retry;

  final Dio _refreshDio;
  final AuthTokenStorage _tokenStorage;
  final RetryRequest _retry;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (_isSkipPath(err.requestOptions.path)) {
      return handler.next(err);
    }
    if (err.requestOptions.headers[_retryHeader] == '1') {
      // Ja retentamos uma vez — desistir para evitar loop.
      return handler.next(err);
    }

    final headerBearer = _extractBearer(
      err.requestOptions.headers['Authorization'],
    );
    final tokenAtual = await _tokenStorage.readAccess();

    // Sem token em storage: nada a refrescar.
    if (tokenAtual == null || tokenAtual.isEmpty) {
      await _tokenStorage.clear();
      return handler.next(err);
    }

    // Token-staleness check: se outro refresh ja completou enquanto esta
    // request estava na fila, basta retentar com o token atual.
    if (headerBearer != null && headerBearer != tokenAtual) {
      return _retentar(err.requestOptions, tokenAtual, handler);
    }

    final refreshToken = await _tokenStorage.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return handler.next(err);
    }

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final novoAccess = data['accessToken'] as String;
      final novoRefresh = data['refreshToken'] as String;
      final accessExpira =
          DateTime.parse(data['accessTokenExpiraEm'] as String);
      final refreshExpira =
          DateTime.parse(data['refreshTokenExpiraEm'] as String);
      await _tokenStorage.saveTokens(
        accessToken: novoAccess,
        refreshToken: novoRefresh,
        accessTokenExpiraEm: accessExpira,
        refreshTokenExpiraEm: refreshExpira,
      );
      return _retentar(err.requestOptions, novoAccess, handler);
    } catch (refreshErr) {
      // Refresh falhou ou backend retornou 401. Limpa storage e propaga
      // o erro original. Quem precisar reagir (UI/router) detecta via
      // proxima chamada autenticada que vai falhar.
      await _tokenStorage.clear();
      if (kDebugMode) {
        debugPrint('[RefreshInterceptor] refresh falhou: $refreshErr');
      }
      return handler.next(err);
    }
  }

  Future<void> _retentar(
    RequestOptions options,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.headers[_retryHeader] = '1';
    try {
      final response = await _retry(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } catch (e) {
      return handler.next(
        DioException(requestOptions: options, error: e),
      );
    }
  }

  String? _extractBearer(dynamic value) {
    if (value is! String) return null;
    if (!value.startsWith('Bearer ')) return null;
    return value.substring('Bearer '.length).trim();
  }
}
