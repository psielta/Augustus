import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/usuario_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

const double _wideBreakpoint = 768.0;

/// Shell de admin do Augustus, paralelo ao `AppLayout` do web.
///
/// Provê:
/// - `AppBar` com titulo, saudacao "Olá, {nome}" (com margem direita
///   antes do icone) e botao de logout com dialogo de confirmacao.
/// - `Drawer` modal no phone (`< 768 dp`) ou drawer permanente em
///   tablet/desktop (`>= 768 dp`) com logo + nome + email do usuario
///   logado, links de navegacao e rodape com copyright.
/// - `body: child` — paginas plugam o conteudo proprio.
///
/// As telas de auth NAO devem usar este shell — elas continuam com
/// `Scaffold` proprio (equivalente ao `AuthLayout` web).
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final appBar = AppBar(
      title: Text(title),
      actions: [
        ...?actions,
        if (usuario != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Olá, ${usuario.nome}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: () => _confirmarSair(context, ref),
        ),
      ],
    );

    if (isWide) {
      // Drawer permanente em telas largas: sem hamburger automatico,
      // sem modal — o drawer fica colado a esquerda do conteudo.
      return Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: 280,
                child: _AugustusDrawer(
                  usuario: usuario,
                  onNavigate: (rota) => _navegar(context, rota, fechar: false),
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    // Phone: drawer modal padrao do Scaffold — Flutter ja injeta o
    // hamburger no AppBar automaticamente quando `drawer` esta presente.
    return Scaffold(
      appBar: appBar,
      drawer: _AugustusDrawer(
        usuario: usuario,
        onNavigate: (rota) => _navegar(context, rota, fechar: true),
      ),
      body: child,
    );
  }

  void _navegar(BuildContext context, String rota, {required bool fechar}) {
    if (fechar) {
      Navigator.of(context).pop(); // fecha o drawer modal
    }
    final rotaAtual =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (rotaAtual != rota) {
      context.go(rota);
    }
  }

  Future<void> _confirmarSair(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ref.read(authProvider.notifier).logout();
    final erro = ref.read(authProvider).errorMessage;
    if (erro != null && context.mounted) {
      AppUtils.showSnackBar(
        context,
        message: erro,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }
}

class _AugustusDrawer extends StatelessWidget {
  const _AugustusDrawer({required this.usuario, required this.onNavigate});

  final UsuarioEntity? usuario;
  final void Function(String rota) onNavigate;

  @override
  Widget build(BuildContext context) {
    final ano = DateTime.now().year;
    final colorScheme = Theme.of(context).colorScheme;
    final rotaAtual =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/brand/augustus-symbol.svg',
                    semanticsLabel: 'Augustus',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Augustus',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (usuario != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      usuario!.email,
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'Início',
                  rota: AppConstants.homeRoute,
                  selecionada: rotaAtual == AppConstants.homeRoute,
                  onNavigate: onNavigate,
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Configurações',
                  rota: AppConstants.settingsRoute,
                  selecionada:
                      rotaAtual.startsWith(AppConstants.settingsRoute),
                  onNavigate: onNavigate,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '© $ano Augustus\nControlador de finanças pessoais',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.rota,
    required this.selecionada,
    required this.onNavigate,
  });

  final IconData icon;
  final String label;
  final String rota;
  final bool selecionada;
  final void Function(String rota) onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selecionada,
      onTap: () => onNavigate(rota),
    );
  }
}
