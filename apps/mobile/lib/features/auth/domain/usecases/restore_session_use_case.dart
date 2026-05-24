import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RestoreSessionUseCase {
  final AuthRepository _repository;

  RestoreSessionUseCase(this._repository);

  Future<Either<Failure, UsuarioEntity?>> execute() =>
      _repository.restaurarSessao();
}
