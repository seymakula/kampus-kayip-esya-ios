import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class CreateItemScreen extends StatelessWidget {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İlan')),
      // Hafta 5: adım adım form, kamera/galeri ve konum seçimi.
      body: const PlaceholderView(
        icon: Icons.add_a_photo_outlined,
        title: 'Yeni ilan',
        message: 'Fotoğraf çekip konumu seçerek ilan açabileceksin.',
      ),
    );
  }
}
