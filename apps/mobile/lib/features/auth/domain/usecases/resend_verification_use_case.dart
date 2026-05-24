import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ResendVerificationUseCase {
  final AuthRepository _repository;

  ResendVerificationUseCase(this._repository);

  Future<Either<Failure, void>> execute({required String email}) {
    final e = email.trim();
    if (e.isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Informe o email')),
      );
    }
    return _repository.reenviarVerificacao(email: e);
  }
}
