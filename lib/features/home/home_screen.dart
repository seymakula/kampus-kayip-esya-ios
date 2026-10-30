import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../shared/widgets/async_value_view.dart';
import 'item_list_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hafta 2 (Barış): Kayıp / Bulunan sekmeleri ve ItemCard bu listenin
    // yerini alacak; her sekme itemListProvider(ItemType.lost / .found) izler.
    final items = ref.watch(itemListProvider(null));

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
      body: AsyncValueView(
        value: items,
        isEmpty: (list) => list.isEmpty,
        emptyIcon: Icons.inventory_2_outlined,
        emptyTitle: 'Henüz ilan yok',
        emptyMessage: 'Kayıp ve bulunan ilanlar burada listelenecek.',
        onRetry: () => ref.invalidate(itemListProvider(null)),
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.read(itemListProvider(null).notifier).refresh(),
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('${item.type.label} · ${item.location.name}'),
                onTap: () => context.push(AppRoutes.itemDetail(item.id)),
              );
            },
          ),
        ),
      ),
    );
  }
}
