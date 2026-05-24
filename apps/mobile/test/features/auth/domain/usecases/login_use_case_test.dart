import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/token_pair_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tSenha = 'senha-super-segura-123';
  final tTokenPair = TokenPairModel(
    accessToken: 'access-jwt',
    refreshToken: 'refresh-opaque',
    accessTokenExpiraEm: DateTime.parse('2026-05-23T12:15:00Z'),
    refreshTokenExpiraEm: DateTime.parse('2026-06-22T12:00:00Z'),
    tokenType: 'Bearer',
  );

  test('repassa para repository quando email/senha sao validos', () async {
    when(
      () => mockAuthRepository.login(email: tEmail, senha: tSenha),
    ).thenAnswer((_) async => Right(tTokenPair));

    final result = await useCase.execute(email: tEmail, senha: tSenha);

    expect(result, Right<Failure, TokenPairModel>(tTokenPair));
    verify(
      () => mockAuthRepository.login(email: tEmail, senha: tSenha),
    ).called(1);
  });

  test('propaga ServerFailure quando repository falha', () async {
    const tFailure = ServerFailure(message: 'oops');
    when(
      () => mockAuthRepository.login(email: tEmail, senha: tSenha),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase.execute(email: tEmail, senha: tSenha);

    expect(result, const Left<Failure, TokenPairModel>(tFailure));
    verify(
      () => mockAuthRepository.login(email: tEmail, senha: tSenha),
    ).called(1);
  });

  test('valida senha vazia sem tocar no repository', () async {
    final result = await useCase.execute(email: tEmail, senha: '');

    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Deveria ter retornado falha'),
    );
    verifyZeroInteractions(mockAuthRepository);
  });

  test('valida senha curta sem tocar no repository', () async {
    final result = await useCase.execute(email: tEmail, senha: 'curta');

    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Deveria ter retornado falha'),
    );
    verifyZeroInteractions(mockAuthRepository);
  });

  test('valida email vazio sem tocar no repository', () async {
    final result = await useCase.execute(email: '   ', senha: tSenha);

    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Deveria ter retornado falha'),
    );
    verifyZeroInteractions(mockAuthRepository);
  });
}
