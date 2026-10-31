import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import 'auth_validators.dart';
import 'widgets/auth_submit.dart';
import 'widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthSubmitMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() => submitForm(() async {
    // Hafta 3 (Şeyma): ref.read(authStateProvider.notifier)
    //     .login(_email.text.trim(), _password.text)
    await Future<void>.delayed(mockAuthDelay);
    if (mounted) context.go(AppRoutes.home);
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.travel_explore,
                      size: 40,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Kampüs Kayıp Eşya',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Okul e-postanla giriş yap.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.schoolEmail,
                  decoration: const InputDecoration(
                    labelText: 'Okul e-postası',
                    hintText: 'ad.soyad@ogrenci.ankara.edu.tr',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: 'Şifre',
                  validator: AuthValidators.loginPassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Giriş yap',
                  busy: busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabın yok mu?'),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => context.push(AppRoutes.register),
                      child: const Text('Kayıt ol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
