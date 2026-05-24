import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/app_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_theme.dart';
import 'package:flutter_riverpod_clean_architecture/core/updates/update_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/app_localizations_delegate.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        defaultLocaleProvider.overrideWith(
          (ref) => ref.watch(persistentLocaleProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Decisao de produto: Augustus e **sempre** light mode. Mantemos o provider
/// para nao quebrar imports legados, mas ele sempre devolve `ThemeMode.light`
/// e `set` e no-op.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void set(ThemeMode mode) {
    // Light mode obrigatorio: ignora qualquer tentativa de mudar.
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Restaura sessao no bootstrap: tenta `/auth/me` se ha refresh em storage.
/// Disparado uma unica vez ao primeiro `watch` do provider.
///
/// `Future.microtask` adia a modificacao do `authProvider` para fora
/// do build do `appBootstrapProvider`. Sem isso, Riverpod 3 lanca
/// `"Providers are not allowed to modify other providers during their
/// initialization"` porque `inicializar()` faz `state = ...` no
/// AuthNotifier enquanto o FutureProvider ainda esta sendo construido.
final appBootstrapProvider = FutureProvider<void>((ref) async {
  await Future.microtask(
    () => ref.read(authProvider.notifier).inicializar(),
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(persistentLocaleProvider);
    final bootstrap = ref.watch(appBootstrapProvider);

    return UpdateChecker(
      autoPrompt: true,
      enforceCriticalUpdates: true,
      child: AccessibilityWrapper(
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          // Sem darkTheme nem themeMode: produto e light-only.
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return bootstrap.when(
              loading: () => const _BootstrapSplash(),
              error: (err, _) => _BootstrapError(message: err.toString()),
              data: (_) => child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Falha ao iniciar o app',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
