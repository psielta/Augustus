import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';

/// Dio dedicado **apenas** para chamadas `/auth/refresh` feitas pelo
/// `RefreshInterceptor`. **Nao** registra nenhum interceptor de auth/refresh
/// nele — se o refresh em si falhar com 401, deve propagar como erro normal,
/// sem disparar outro refresh em cascata.
final refreshDioProvider = Provider<Dio>((ref) {
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
  return dio;
});
