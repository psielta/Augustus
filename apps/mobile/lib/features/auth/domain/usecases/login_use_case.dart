import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/token_pair_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, TokenPairModel>> execute({
    required String email,
    required String senha,
  }) {
    if (email.trim().isEmpty || senha.isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Informe email e senha')),
      );
    }
    if (senha.length < 8) {
      return Future.value(
        const Left(InputFailure(message: 'A senha tem no minimo 8 caracteres')),
      );
    }
    return _repository.login(email: email.trim(), senha: senha);
  }
}
