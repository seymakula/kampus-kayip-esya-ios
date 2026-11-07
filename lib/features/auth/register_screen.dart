import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/auth_provider.dart';
import 'auth_validators.dart';
import 'widgets/auth_submit.dart';
import 'widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with AuthSubmitMixin {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _studentNo = TextEditingController();
  final _password = TextEditingController();
  final _passwordAgain = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _email,
      _studentNo,
      _password,
      _passwordAgain,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Map<String, TextEditingController> get serverFields => {
    'fullName': _fullName,
    'email': _email,
    'studentNo': _studentNo,
    'password': _password,
    'confirmPassword': _passwordAgain,
  };

  // Başarılı olunca oturum değişir, router ana sayfaya yönlendirir.
  Future<void> _submit() => submitForm(
    () => ref
        .read(authStateProvider.notifier)
        .register(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          studentNo: _studentNo.text.trim(),
          password: _password.text,
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  validator: withServerError(
                    'fullName',
                    AuthValidators.fullName,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Ad soyad',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: withServerError(
                    'email',
                    AuthValidators.schoolEmail,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Okul e-postası',
                    hintText: 'ad.soyad@ogrenci.ankara.edu.tr',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentNo,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: withServerError(
                    'studentNo',
                    AuthValidators.studentNo,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci / personel no',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: 'Şifre',
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                  validator: withServerError(
                    'password',
                    AuthValidators.newPassword,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'En az ${AuthValidators.minPasswordLength} karakter, '
                    'bir harf ve bir rakam.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordAgain,
                  label: 'Şifre (tekrar)',
                  autofillHints: const [AutofillHints.newPassword],
                  validator: withServerError(
                    'confirmPassword',
                    AuthValidators.confirmPassword(() => _password.text),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Kayıt ol',
                  busy: busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
