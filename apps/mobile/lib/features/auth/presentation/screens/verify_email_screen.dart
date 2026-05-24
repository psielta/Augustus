import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

/// Tela de fallback "colar token". Como deep link foi adiado, o usuario abre
/// o email num navegador, copia o `?token=...` do link e cola aqui.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Permite passar `?token=...` direto (caso o usuario cole o link inteiro
    // via outro fluxo). Roda no proximo frame para o ref estar disponivel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final raw = GoRouterState.of(context).uri.queryParameters['token'];
      if (raw != null && raw.isNotEmpty) {
        _tokenController.text = raw;
      }
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final token = _tokenController.text.trim();
    await ref.read(authProvider.notifier).verificarEmail(token: token);
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.lastFailure != null) {
      AppUtils.showSnackBar(
        context,
        message: authState.lastFailure!.message,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    AppUtils.showSnackBar(
      context,
      message: 'Email verificado. Faca login para continuar.',
    );
    context.go('${AppConstants.loginRoute}?verificado=1');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar email'),
        leading: BackButton(
          onPressed: () => context.go(AppConstants.verifyPendingRoute),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.vpn_key, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Colar token de verificacao',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Abra o email que enviamos, copie o valor do parametro '
                    '"token" do link e cole abaixo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _tokenController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Token',
                      hintText: 'Cole o token aqui',
                      prefixIcon: Icon(Icons.paste_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o token';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _verificar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Verificar email'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.go(AppConstants.verifyPendingRoute),
                    child: const Text('Voltar'),
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
