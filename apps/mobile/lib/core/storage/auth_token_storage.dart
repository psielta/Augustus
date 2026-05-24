import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

/// Wrapper de alto nivel sobre [SecureStorageService] dedicado aos tokens
/// de autenticacao Augustus.
///
/// Regra de produto: tokens **so** vivem em `flutter_secure_storage`. Nunca
/// gravar em `shared_preferences`, `Hive` aberto ou em memoria persistente.
class AuthTokenStorage {
  AuthTokenStorage(this._secure);

  final SecureStorageService _secure;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiraEm,
    required DateTime refreshTokenExpiraEm,
  }) async {
    await Future.wait([
      _secure.write(key: AppConstants.accessTokenKey, value: accessToken),
      _secure.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      _secure.write(
        key: AppConstants.accessTokenExpiraEmKey,
        value: accessTokenExpiraEm.toIso8601String(),
      ),
      _secure.write(
        key: AppConstants.refreshTokenExpiraEmKey,
        value: refreshTokenExpiraEm.toIso8601String(),
      ),
    ]);
  }

  Future<String?> readAccess() =>
      _secure.read(key: AppConstants.accessTokenKey);

  Future<String?> readRefresh() =>
      _secure.read(key: AppConstants.refreshTokenKey);

  Future<DateTime?> readAccessExpiraEm() async {
    final raw = await _secure.read(key: AppConstants.accessTokenExpiraEmKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> hasRefresh() async {
    final v = await readRefresh();
    return v != null && v.isNotEmpty;
  }

  Future<void> clear() async {
    await Future.wait([
      _secure.delete(key: AppConstants.accessTokenKey),
      _secure.delete(key: AppConstants.refreshTokenKey),
      _secure.delete(key: AppConstants.accessTokenExpiraEmKey),
      _secure.delete(key: AppConstants.refreshTokenExpiraEmKey),
    ]);
  }
}

/// Provider do `SecureStorageService` reutilizavel para qualquer feature
/// que precise de storage seguro.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});

/// Provider do `AuthTokenStorage`. Use este em vez de tocar
/// `SecureStorageService` direto para auth.
final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return AuthTokenStorage(ref.watch(secureStorageServiceProvider));
});
