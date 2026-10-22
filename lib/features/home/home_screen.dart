import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../shared/widgets/placeholder_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampüs Kayıp Eşya'),
        actions: [
          IconButton(
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      // Hafta 2: Kayıp / Bulunan sekmeleri ve ilan kartları.
      body: const PlaceholderView(
        icon: Icons.inventory_2_outlined,
        title: 'İlanlar',
        message: 'Kayıp ve bulunan ilanlar burada listelenecek.',
      ),
    );
  }
}
