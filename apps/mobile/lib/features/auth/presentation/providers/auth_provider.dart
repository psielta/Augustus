import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/providers/auth_providers.dart';

/// Estado da sessao de autenticacao.
enum AuthStatus { inicializando, anonimo, autenticado }

class AuthState extends Equatable {
  final AuthStatus status;
  final UsuarioEntity? usuario;
  final bool isLoading;
  final Failure? lastFailure;

  /// Sinaliza que o backend devolveu `EMAIL_NAO_VERIFICADO` ou que o cadastro
  /// foi recem-criado e o usuario precisa verificar antes de logar.
  final bool precisaVerificarEmail;
  final String? emailEmVerificacao;

  const AuthState({
    this.status = AuthStatus.inicializando,
    this.usuario,
    this.isLoading = false,
    this.lastFailure,
    this.precisaVerificarEmail = false,
    this.emailEmVerificacao,
  });

  bool get isAuthenticated => status == AuthStatus.autenticado;
  String? get errorMessage => lastFailure?.message;

  AuthState copyWith({
    AuthStatus? status,
    UsuarioEntity? usuario,
    bool? usuarioNull,
    bool? isLoading,
    Failure? lastFailure,
    bool? lastFailureNull,
    bool? precisaVerificarEmail,
    String? emailEmVerificacao,
    bool? emailEmVerificacaoNull,
  }) {
    return AuthState(
      status: status ?? this.status,
      usuario: (usuarioNull ?? false) ? null : (usuario ?? this.usuario),
      isLoading: isLoading ?? this.isLoading,
      lastFailure:
          (lastFailureNull ?? false) ? null : (lastFailure ?? this.lastFailure),
      precisaVerificarEmail:
          precisaVerificarEmail ?? this.precisaVerificarEmail,
      emailEmVerificacao: (emailEmVerificacaoNull ?? false)
          ? null
          : (emailEmVerificacao ?? this.emailEmVerificacao),
    );
  }

  @override
  List<Object?> get props => [
        status,
        usuario,
        isLoading,
        lastFailure,
        precisaVerificarEmail,
        emailEmVerificacao,
      ];
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  /// Restaura a sessao no bootstrap. Idempotente.
  Future<void> inicializar() async {
    state = state.copyWith(
      status: AuthStatus.inicializando,
      isLoading: true,
      lastFailureNull: true,
    );
    final result = await ref.read(restoreSessionUseCaseProvider).execute();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.anonimo,
        usuarioNull: true,
        isLoading: false,
        lastFailure: failure,
      ),
      (usuario) => state = state.copyWith(
        status: usuario == null ? AuthStatus.anonimo : AuthStatus.autenticado,
        usuario: usuario,
        usuarioNull: usuario == null,
        isLoading: false,
        lastFailureNull: true,
      ),
    );
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state = state.copyWith(isLoading: true, lastFailureNull: true);
    final result = await ref
        .read(registerUseCaseProvider)
        .execute(nome: nome, email: email, senha: senha);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        lastFailure: failure,
      ),
      (registro) => state = state.copyWith(
        isLoading: false,
        status: AuthStatus.anonimo,
        precisaVerificarEmail: true,
        emailEmVerificacao: registro.usuario.email,
        lastFailureNull: true,
      ),
    );
  }

  Future<void> login({required String email, required String senha}) async {
    state = state.copyWith(isLoading: true, lastFailureNull: true);
    final loginResult = await ref
        .read(loginUseCaseProvider)
        .execute(email: email, senha: senha);

    await loginResult.fold(
      (failure) async {
        state = state.copyWith(
          isLoading: false,
          lastFailure: failure,
          precisaVerificarEmail: failure is EmailNaoVerificadoFailure,
          emailEmVerificacao:
              failure is EmailNaoVerificadoFailure ? email : null,
        );
      },
      (_) async {
        // Login OK — tokens salvos pelo repository. Agora busca o usuario.
        final meResult = await ref.read(getCurrentUserUseCaseProvider).execute();
        meResult.fold(
          (failure) => state = state.copyWith(
            isLoading: false,
            status: AuthStatus.anonimo,
            lastFailure: failure,
          ),
          (usuario) => state = state.copyWith(
            status: AuthStatus.autenticado,
            usuario: usuario,
            isLoading: false,
            precisaVerificarEmail: false,
            emailEmVerificacaoNull: true,
            lastFailureNull: true,
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, lastFailureNull: true);
    await ref.read(logoutUseCaseProvider).execute();
    state = const AuthState(status: AuthStatus.anonimo);
  }

  Future<void> verificarEmail({required String token}) async {
    state = state.copyWith(isLoading: true, lastFailureNull: true);
    final result = await ref
        .read(verifyEmailUseCaseProvider)
        .execute(token: token);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        lastFailure: failure,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        precisaVerificarEmail: false,
        emailEmVerificacaoNull: true,
        lastFailureNull: true,
      ),
    );
  }

  Future<void> reenviarVerificacao({required String email}) async {
    state = state.copyWith(isLoading: true, lastFailureNull: true);
    final result = await ref
        .read(resendVerificationUseCaseProvider)
        .execute(email: email);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        lastFailure: failure,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        lastFailureNull: true,
      ),
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
