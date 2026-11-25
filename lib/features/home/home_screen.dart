import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/paged_item_list_view.dart';
import '../../shared/widgets/tag_badge.dart';
import '../search/active_filter_chips.dart';
import '../search/filter_sheet.dart';
import '../search/search_providers.dart';
import 'item_list_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(homeFilterProvider);
    final notifier = ref.read(homeFilterProvider.notifier);
    final filterCount = filter.sheetFilterCount;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Web'deki gibi logo solda; dar ekranda ad kısalır, taşmaz.
          centerTitle: false,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Kampüs Kayıp Eşya',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Kategori, bina, tarih; Ara ekranındaki panelin aynısı.
            IconButton(
              tooltip: 'Filtrele',
              icon: Badge(
                isLabelVisible: filterCount > 0,
                label: Text('$filterCount'),
                child: const Icon(Icons.tune),
              ),
              onPressed: () async {
                final result = await showFilterSheet(context, filter);
                if (result != null) notifier.apply(result);
              },
            ),
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
        body: Column(
          children: [
            if (filterCount > 0)
              ActiveFilterChips(filter: filter, notifier: notifier),
            Expanded(
              child: TabBarView(
                children: [
                  _ItemListTab(type: ItemType.lost, filtered: filterCount > 0),
                  _ItemListTab(type: ItemType.found, filtered: filterCount > 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bir sekmenin ilan listesi. Sekme değişince kaydırma konumu korunur.
class _ItemListTab extends ConsumerStatefulWidget {
  const _ItemListTab({required this.type, required this.filtered});

  final ItemType type;

  /// Filtre açıkken boş liste "ilan yok" değil "filtreye uyan yok" der.
  final bool filtered;

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
      emptyIcon: widget.filtered
          ? Icons.filter_alt_off_outlined
          : lost
          ? Icons.search_off
          : Icons.inventory_2_outlined,
      emptyTitle: widget.filtered
          ? 'Filtrelere uyan ilan yok'
          : lost
          ? 'Kayıp ilanı yok'
          : 'Bulunan ilanı yok',
      emptyMessage: widget.filtered
          ? 'Filtreleri azaltmayı ya da kaldırmayı dene.'
          : 'Yeni ilanlar burada görünecek.',
    );
  }
}
