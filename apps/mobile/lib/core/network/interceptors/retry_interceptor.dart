import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that retries failed requests
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final attempt = err.requestOptions.headers['retry_attempt'] ?? 0;

      if (attempt < maxRetries && attempt < retryDelays.length) {
        final delay = retryDelays[attempt];
        debugPrint(
          '🔄 Retry attempt ${attempt + 1}/$maxRetries for ${err.requestOptions.path} after ${delay.inSeconds}s',
        );

        // Update retry attempt count
        err.requestOptions.headers['retry_attempt'] = attempt + 1;

        // Wait before retrying
        await Future.delayed(delay);

        try {
          // Clone the request and retry
          final options = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            followRedirects: err.requestOptions.followRedirects,
            listFormat: err.requestOptions.listFormat,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            validateStatus: err.requestOptions.validateStatus,
            extra: err.requestOptions.extra,
          );

          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            cancelToken: err.requestOptions.cancelToken,
            options: options,
            onSendProgress: err.requestOptions.onSendProgress,
            onReceiveProgress: err.requestOptions.onReceiveProgress,
          );

          return handler.resolve(response);
        } catch (e) {
          // If retry fails, passed error will be handled by next error
          return super.onError(err, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Caller pode marcar um request individual como nao-retentavel com
    // `Options(extra: {'noRetry': true})` — usado por mutacoes de auth e
    // por qualquer chamada que ja garanta idempotencia em outra camada.
    if (err.requestOptions.extra['noRetry'] == true) {
      return false;
    }

    // Retry apenas em metodos idempotentes. POST/PUT/PATCH/DELETE podem
    // ter side-effects (criar usuario, enviar email, registrar tentativa
    // de login bloqueada) — repetir e perigoso.
    final method = err.requestOptions.method.toUpperCase();
    const idempotent = {'GET', 'HEAD', 'OPTIONS'};
    if (!idempotent.contains(method)) {
      return false;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.type == DioExceptionType.unknown &&
            err.error != null &&
            err.error is SocketException);
  }
}
