import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlan Detayı')),
      // Hafta 4: fotoğraf galerisi, açıklama, konum ve "Bu benim".
      body: PlaceholderView(
        icon: Icons.description_outlined,
        title: 'İlan #$itemId',
        message: 'İlanın fotoğrafları ve ayrıntıları burada görünecek.',
      ),
    );
  }
}
