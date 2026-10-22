import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // Hafta 4: profil, ayarlar ve çıkış.
      body: const PlaceholderView(
        icon: Icons.account_circle_outlined,
        title: 'Profil',
        message: 'İlanların, taleplerin ve ayarların burada olacak.',
      ),
    );
  }
}
