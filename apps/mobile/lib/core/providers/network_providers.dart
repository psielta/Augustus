import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/refresh_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../network/interceptors/safe_log_interceptor.dart';
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
  //   1. AuthInterceptor — injeta Bearer antes do log.
  //   2. SafeLogInterceptor — loga so method+path+status, **nunca**
  //      headers ou body. O LogInterceptor padrao do Dio vazaria senha
  //      (em /auth/login) e tokens (em /auth/refresh) caso `requestBody`
  //      ou `responseBody` ficassem true.
  //   3. RetryInterceptor — retries APENAS em metodos idempotentes
  //      (GET/HEAD/OPTIONS) ou quando o caller marca explicitamente
  //      `extra: {'noRetry': true}`.
  //   4. RefreshInterceptor — refresh single-flight em 401, com
  //      `_retry: (opts) => dio.fetch(opts)` capturando `dio` por closure
  //      (referencia ja existe quando o callback roda).
  dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));
  dio.interceptors.add(SafeLogInterceptor());
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
