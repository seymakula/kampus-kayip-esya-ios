import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/paged_item_list_view.dart';
import 'item_list_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kampüs Kayıp Eşya'),
          actions: [
            IconButton(
              tooltip: 'Bildirimler',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push(AppRoutes.notifications),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kayıp'),
              Tab(text: 'Bulunan'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ItemListTab(type: ItemType.lost),
            _ItemListTab(type: ItemType.found),
          ],
        ),
      ),
    );
  }
}

/// Bir sekmenin ilan listesi. Sekme değişince kaydırma konumu korunur.
class _ItemListTab extends ConsumerStatefulWidget {
  const _ItemListTab({required this.type});

  final ItemType type;

  @override
  ConsumerState<_ItemListTab> createState() => _ItemListTabState();
}

class _ItemListTabState extends ConsumerState<_ItemListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = itemListProvider(widget.type);
    final lost = widget.type == ItemType.lost;

    return PagedItemListView(
      value: ref.watch(provider),
      onRefresh: () => ref.read(provider.notifier).refresh(),
      onLoadMore: () => ref.read(provider.notifier).loadMore(),
      onRetry: () => ref.invalidate(provider),
      emptyIcon: lost ? Icons.search_off : Icons.inventory_2_outlined,
      emptyTitle: lost ? 'Kayıp ilanı yok' : 'Bulunan ilanı yok',
    );
  }
}
