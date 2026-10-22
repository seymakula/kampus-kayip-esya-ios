import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      // Hafta 2: kayıt formu ve doğrulama.
      body: const PlaceholderView(
        icon: Icons.person_add_alt,
        title: 'Kayıt',
        message: 'Okul e-postan ve öğrenci numaranla kayıt olabileceksin.',
      ),
    );
  }
}
