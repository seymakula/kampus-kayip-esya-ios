import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      // Hafta 7: SignalR ile sohbet.
      body: const PlaceholderView(
        icon: Icons.forum_outlined,
        title: 'Sohbetler',
        message: 'Talebin onaylanınca ilan sahibiyle buradan mesajlaşacaksın.',
      ),
    );
  }
}
