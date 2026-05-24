import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/register_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/resend_verification_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/verify_email_use_case.dart';

// Auth use cases: providers Riverpod simples (sem codegen).
// `authRepositoryProvider` mora em auth_repository_impl.dart.

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) {
  return VerifyEmailUseCase(ref.watch(authRepositoryProvider));
});

final resendVerificationUseCaseProvider =
    Provider<ResendVerificationUseCase>((ref) {
  return ResendVerificationUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});
