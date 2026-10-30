import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ara')),
      // Hafta 3: arama ve filtre (kategori, bina, tarih).
      body: const PlaceholderView(
        icon: Icons.manage_search,
        title: 'Ara ve filtrele',
        message: 'Kategori, bina ve tarihe göre ilan arayabileceksin.',
      ),
    );
  }
}
