import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';

/// Chave de persistencia do estado aberto/fechado da sidebar. Mesma
/// convencao do web (`augustus.ui.menuOpen` em `localStorage`).
const _menuOpenKey = 'augustus.ui.menuOpen';

/// Persiste a preferencia "drawer aberto" em SharedPreferences seguindo
/// o mesmo padrao de `PersistentLocaleNotifier`.
///
/// So faz sentido em viewports largos (`>= 768 dp`), onde o drawer e
/// renderizado como sidebar permanente e o usuario pode escolher
/// recolhe-lo via hamburger. Em telas estreitas o Drawer e modal e o
/// estado e efemero (abre via tap, fecha via tap fora) — o consumer
/// (`AppShell`) ignora esse provider em viewports pequenos.
class MenuOpenNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_menuOpenKey) ?? true;
  }

  Future<void> toggle() async => set(!state);

  Future<void> set(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_menuOpenKey, value);
    state = value;
  }
}

final menuOpenProvider = NotifierProvider<MenuOpenNotifier, bool>(
  MenuOpenNotifier.new,
);
