import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/app_shell.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

/// Tela de configuracoes do Augustus. Usa o [AppShell] para herdar o
/// chrome admin (AppBar com saudacao + Sair + Drawer com navegacao).
///
/// Por enquanto so expoe a sub-tela de idioma — theme switcher foi
/// removido (produto e light-only) e notifications fica para fatia
/// futura quando houver backend de notificacao.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppShell(
      title: context.tr('settings'),
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            subtitle: Text(context.tr('change_language')),
            onTap: () => context.go(AppConstants.languageSettingsRoute),
          ),
        ],
      ),
    );
  }
}
