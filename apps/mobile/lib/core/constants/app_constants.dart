import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Valor capturado em compile-time via `--dart-define=API_BASE_URL=...`.
/// `String.fromEnvironment` exige default `const`, por isso a string vazia.
const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

class AppConstants {
  // ----- API -----
  /// Base URL do backend Augustus.
  ///
  /// Prioridade:
  /// 1. `--dart-define=API_BASE_URL=...` (qualquer plataforma).
  /// 2. Default por plataforma em runtime (usa `kIsWeb` + `defaultTargetPlatform`
  ///    para nao depender de `dart:io`, mantendo compatibilidade com Flutter Web).
  static String get apiBaseUrl =>
      _envBaseUrl.isNotEmpty ? _envBaseUrl : _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 e o loopback do host visto pelo Android emulator
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  // ----- Secure storage keys -----
  static const String accessTokenKey = 'augustus.auth.accessToken';
  static const String refreshTokenKey = 'augustus.auth.refreshToken';
  static const String accessTokenExpiraEmKey =
      'augustus.auth.accessTokenExpiraEm';
  static const String refreshTokenExpiraEmKey =
      'augustus.auth.refreshTokenExpiraEm';

  // ----- App -----
  static const String appName = 'Augustus - Controlador de finanças pessoais';
  static const String appVersion = '1.0.0';
  // Package Android/iOS continua o do template ate o renomeio oficial:
  static const String packageName =
      'com.example.flutter_riverpod_clean_architecture';
  static const String iOSAppId = '123456789';
  static const String appcastUrl = 'https://your-appcast-url.com/appcast.xml';

  // ----- Timeouts (ms) -----
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ----- Rotas -----
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String verifyPendingRoute = '/auth/verify-pending';
  static const String verifyEmailRoute = '/auth/verify-email';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String languageSettingsRoute = '/settings/language';

  // ----- Hive box names -----
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineSyncBox = 'offlineSync';

  // ----- Animation durations -----
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // ----- Accessibility -----
  static const Duration accessibilityTooltipDuration = Duration(seconds: 5);
  static const double accessibilityTouchTargetMinSize = 48.0;

  // ----- App Review -----
  static const int minSessionsBeforeReview = 5;
  static const int minDaysBeforeReview = 7;
  static const int minActionsBeforeReview = 10;
}
