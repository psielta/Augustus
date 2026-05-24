import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/refresh_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../network/refresh_dio_provider.dart';
import '../storage/auth_token_storage.dart';

part 'network_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final tokenStorage = ref.read(authTokenStorageProvider);
  final refreshDio = ref.read(refreshDioProvider);

  // Ordem dos interceptors:
  //   1. AuthInterceptor — injeta Bearer ANTES do log (assim o LogInterceptor
  //      ate poderia logar o header, mas mantemos `requestHeader: false`
  //      por seguranca para nao vazar tokens em prod).
  //   2. LogInterceptor — sem `requestHeader` para nao vazar Bearer.
  //   3. RetryInterceptor — retries de timeout/SocketException.
  //   4. RefreshInterceptor — refresh single-flight em 401, com
  //      `_retry: (opts) => dio.fetch(opts)` capturando o proprio `dio`
  //      por closure (referencia ja existe quando o callback roda).
  dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
  );
  dio.interceptors.add(RetryInterceptor(dio: dio));
  dio.interceptors.add(
    RefreshInterceptor(
      refreshDio: refreshDio,
      tokenStorage: tokenStorage,
      retry: (options) => dio.fetch(options),
    ),
  );

  return dio;
}
