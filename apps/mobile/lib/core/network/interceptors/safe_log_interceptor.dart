import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Substitui o `LogInterceptor` padrao do Dio com uma versao que NUNCA
/// loga body ou headers sensiveis.
///
/// Motivacao: o `LogInterceptor` do Dio aceita flags `requestBody`/
/// `responseBody`, mas elas valem para todas as rotas. As rotas
/// `/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/verify-email`
/// e `/auth/resend-verification` carregam senha em body, ou devolvem
/// `accessToken`/`refreshToken` em response. Habilitar body logging
/// expoe esses segredos em logcat/console — risco em build dev e
/// inadmissivel em release.
///
/// Esta classe so loga linha-resumo:
///   `--> METHOD /path` no request, `<-- status METHOD /path` no response
///   e `xx ERROR METHOD /path` no erro. Sem body, sem headers.
class SafeLogInterceptor extends Interceptor {
  SafeLogInterceptor({void Function(String?)? logPrint})
      : logPrint = logPrint ?? debugPrint;

  final void Function(String?) logPrint;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    logPrint('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logPrint(
      '<-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logPrint(
      'xx ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    handler.next(err);
  }
}
