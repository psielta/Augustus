import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

/// Tela mostrada apos register ou apos login retornar `EMAIL_NAO_VERIFICADO`.
/// O usuario precisa abrir o link no email; como deep link foi adiado nesta
/// fatia, oferecemos um botao "Ja tenho o token" que leva para
/// `VerifyEmailScreen` (paste-token fallback).
class VerifyPendingScreen extends ConsumerWidget {
  const VerifyPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final routerState = GoRouterState.of(context);
    final emailFromQuery = routerState.uri.queryParameters['email'];
    final email = emailFromQuery ?? authState.emailEmVerificacao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifique seu email'),
        leading: BackButton(
          onPressed: () => context.go(AppConstants.loginRoute),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 96, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Verifique seu email',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  email != null
                      ? 'Enviamos um link de verificacao para $email.'
                      : 'Enviamos um link de verificacao para o seu email.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Abra a mensagem e clique no link para liberar o login. '
                  'O link expira em 24 horas.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: authState.isLoading || email == null
                      ? null
                      : () async {
                          await ref
                              .read(authProvider.notifier)
                              .reenviarVerificacao(email: email);
                          if (!context.mounted) return;
                          AppUtils.showSnackBar(
                            context,
                            message:
                                'Se sua conta existir, enviamos um novo email. Aguarde alguns minutos.',
                          );
                        },
                  icon: const Icon(Icons.send),
                  label: Text(authState.isLoading
                      ? 'Reenviando...'
                      : 'Reenviar email'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go(AppConstants.verifyEmailRoute),
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: const Text('Ja tenho o token (colar manualmente)'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(AppConstants.loginRoute),
                  child: const Text('Voltar para login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
