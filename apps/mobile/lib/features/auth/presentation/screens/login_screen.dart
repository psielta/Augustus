import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _flashConsumido = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _maybeShowFlash() {
    if (_flashConsumido) return;
    final uri = GoRouterState.of(context).uri;
    String? msg;
    Color? bg;
    if (uri.queryParameters['verificado'] == '1') {
      msg = 'Email verificado. Faca login para continuar.';
      bg = Theme.of(context).colorScheme.primary;
    } else if (uri.queryParameters['logout'] == '1') {
      msg = 'Voce saiu com seguranca.';
    }
    if (msg != null) {
      _flashConsumido = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppUtils.showSnackBar(
          context,
          message: msg!,
          backgroundColor: bg,
        );
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final senha = _passwordController.text;
    await ref.read(authProvider.notifier).login(email: email, senha: senha);

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.lastFailure != null) {
      _showFailure(authState.lastFailure!);
    } else if (authState.isAuthenticated) {
      context.go(AppConstants.homeRoute);
    }
  }

  Future<void> _reenviarVerificacao() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppUtils.showSnackBar(
        context,
        message: 'Informe seu email no campo acima.',
      );
      return;
    }
    await ref.read(authProvider.notifier).reenviarVerificacao(email: email);
    if (!mounted) return;
    AppUtils.showSnackBar(
      context,
      message:
          'Se sua conta existir, enviamos um novo email. Aguarde alguns minutos.',
    );
  }

  void _showFailure(Failure failure) {
    AppUtils.showSnackBar(
      context,
      message: failure.message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    _maybeShowFlash();
    final authState = ref.watch(authProvider);
    final mostraReenviar =
        authState.lastFailure is EmailNaoVerificadoFailure ||
            authState.precisaVerificarEmail;

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Augustus',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Controlador de finanças pessoais',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe seu email';
                      }
                      if (!AppUtils.isValidEmail(value.trim())) {
                        return 'Email invalido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe sua senha';
                      }
                      if (value.length < 8) {
                        return 'Minimo 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                  if (mostraReenviar) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: authState.isLoading ? null : _reenviarVerificacao,
                      child: const Text('Reenviar email de verificacao'),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppConstants.verifyEmailRoute),
                      child: const Text('Ja tenho o token'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nao tem uma conta?'),
                      TextButton(
                        onPressed: () =>
                            context.go(AppConstants.registerRoute),
                        child: const Text('Cadastrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
