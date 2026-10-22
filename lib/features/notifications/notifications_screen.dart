import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      // Hafta 7: bildirim listesi ve okunmamış rozeti.
      body: const PlaceholderView(
        icon: Icons.notifications_none,
        title: 'Bildirim yok',
        message: 'Talepler ve mesajlarla ilgili bildirimler burada görünecek.',
      ),
    );
  }
}
