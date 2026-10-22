import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      // Hafta 2: okul e-postası ve şifre formu.
      body: const PlaceholderView(
        icon: Icons.login,
        title: 'Giriş',
        message: 'Okul e-postanla giriş yapabileceksin.',
      ),
    );
  }
}
