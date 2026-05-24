import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/app_shell.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

/// Tela inicial do admin: card de boas-vindas com o nome/email do usuario
/// e placeholder do dashboard financeiro (a ser implementado em fatias
/// futuras seguindo o blueprint em
/// `docs/database/blueprints/2026-05-23-augustus-multiusuario/`).
///
/// O chrome (AppBar com saudacao + Sair, Drawer com navegacao, rodape)
/// vem do [AppShell] e nao precisa ser definido aqui.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authProvider).usuario;
    final colorScheme = Theme.of(context).colorScheme;

    return AppShell(
      title: 'Início',
      child: usuario == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            usuario.nome.isNotEmpty
                                ? usuario.nome.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, ${usuario.nome}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                usuario.email,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Dashboard financeiro em breve',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Em breve você poderá cadastrar contas, cartões e '
                          'orçamentos, acompanhar lançamentos e parcelamentos, '
                          'e visualizar o estado do seu dinheiro em um só lugar.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
