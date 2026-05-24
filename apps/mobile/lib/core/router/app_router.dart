import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/examples/localization_assets_demo.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/verify_pending_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/presentation/screens/survey_screen.dart';
import 'package:go_router/go_router.dart';

const _publicAuthRoutes = <String>{
  AppConstants.loginRoute,
  AppConstants.registerRoute,
  AppConstants.verifyPendingRoute,
  AppConstants.verifyEmailRoute,
};

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  ref.watch(persistentLocaleProvider);

  return GoRouter(
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthRoute = _publicAuthRoutes.contains(loc);

      // Durante restauracao da sessao no bootstrap, nao redirecionamos:
      // a UI mostra splash via appBootstrapProvider em main.dart.
      if (authState.status == AuthStatus.inicializando) {
        return null;
      }

      if (authState.isAuthenticated) {
        // Logado: sair das telas de auth (verify-email pode ser util mesmo
        // logado se o usuario tiver acabado de verificar e quiser ver
        // mensagem, mas vamos manter consistencia e levar para home).
        if (isAuthRoute) return AppConstants.homeRoute;
        return null;
      }

      // Anonimo. Se ha cadastro recem-criado pendente de verificacao, leva
      // para verify-pending por default — mas permite login (caso o user
      // queira tentar mesmo assim), verify-pending e verify-email.
      if (authState.precisaVerificarEmail) {
        if (loc == AppConstants.loginRoute ||
            loc == AppConstants.verifyPendingRoute ||
            loc == AppConstants.verifyEmailRoute) {
          return null;
        }
        return AppConstants.verifyPendingRoute;
      }

      // Anonimo sem cadastro pendente: so permite rotas publicas de auth.
      if (!isAuthRoute) return AppConstants.loginRoute;
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.verifyPendingRoute,
        name: 'verify_pending',
        builder: (context, state) => const VerifyPendingScreen(),
      ),
      GoRoute(
        path: AppConstants.verifyEmailRoute,
        name: 'verify_email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.languageSettingsRoute,
        name: 'language_settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.localizationAssetsDemoRoute,
        name: 'localization_assets_demo',
        builder: (context, state) => const LocalizationAssetsDemo(),
      ),
      GoRoute(
        path: AppConstants.chatRoute,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppConstants.surveyRoute,
        name: 'survey',
        builder: (context, state) => const SurveyScreen(),
      ),
      GoRoute(
        path: AppConstants.initialRoute,
        name: 'initial',
        redirect: (context, state) => authState.isAuthenticated
            ? AppConstants.homeRoute
            : AppConstants.loginRoute,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Pagina nao encontrada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('A pagina ${state.uri.path} nao foi encontrada'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Ir para home'),
            ),
          ],
        ),
      ),
    ),
  );
});
