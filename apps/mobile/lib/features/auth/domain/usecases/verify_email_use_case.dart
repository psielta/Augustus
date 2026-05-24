import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, void>> execute({required String token}) {
    final t = token.trim();
    if (t.isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Informe o token de verificacao')),
      );
    }
    return _repository.verificarEmail(token: t);
  }
}
