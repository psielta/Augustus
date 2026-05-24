import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/problem_detail.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Either<Failure, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<Failure, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<Failure, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  Future<Either<Failure, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Mapeia erro Dio para `Failure`, priorizando o body em formato
  /// `application/problem+json` que o backend Augustus retorna (RFC 7807).
  Failure _handleError(DioException e) {
    // Timeouts e cancel
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
        if (e.error is Object && e.error.toString().contains('SocketException')) {
          return const NetworkFailure();
        }
        break;
      case DioExceptionType.badCertificate:
        return const ServerFailure(message: 'Certificado invalido');
      case DioExceptionType.badResponse:
        break;
    }

    // badResponse ou unknown com response: tentar parsear ProblemDetail
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      try {
        return ProblemDetail.fromJson(data).toFailure();
      } catch (_) {
        // Cai para o fallback abaixo.
      }
    }
    return ServerFailure(
      message: 'Erro no servidor',
      statusCode: e.response?.statusCode,
    );
  }
}
