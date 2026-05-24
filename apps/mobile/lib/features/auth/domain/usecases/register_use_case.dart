import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/registro_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, RegistroModel>> execute({
    required String nome,
    required String email,
    required String senha,
  }) {
    if (nome.trim().isEmpty || email.trim().isEmpty || senha.isEmpty) {
      return Future.value(
        const Left(InputFailure(message: 'Preencha todos os campos')),
      );
    }
    if (senha.length < 8 || senha.length > 128) {
      return Future.value(
        const Left(
          InputFailure(message: 'A senha deve ter entre 8 e 128 caracteres'),
        ),
      );
    }
    if (nome.trim().length > 120) {
      return Future.value(
        const Left(InputFailure(message: 'Nome muito longo (max 120)')),
      );
    }
    return _repository.registrar(
      nome: nome.trim(),
      email: email.trim(),
      senha: senha,
    );
  }
}
