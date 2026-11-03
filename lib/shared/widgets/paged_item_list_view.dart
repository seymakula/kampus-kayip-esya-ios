import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../data/api/app_exception.dart';
import '../paging/paged_items.dart';
import 'async_value_view.dart';
import 'item_card.dart';

/// [PagedItemsNotifier] listesini gösterir: aşağı çekip yenileme,
/// sona gelince sonraki sayfa, karta dokununca ilan detayı.
class PagedItemListView extends StatelessWidget {
  const PagedItemListView({
    super.key,
    required this.value,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    this.emptyIcon = Icons.inventory_2_outlined,
    this.emptyTitle = 'İlan yok',
    this.emptyMessage = 'Yeni ilanlar burada görünecek.',
  });

  final AsyncValue<PagedItems> value;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return AsyncValueView(
      value: value,
      isEmpty: (page) => page.items.isEmpty,
      emptyIcon: emptyIcon,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      onRetry: onRetry,
      data: (page) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: page.items.length + (page.hasMore ? 1 : 0),
          separatorBuilder: (context, i) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == page.items.length) {
              return _LoadMoreFooter(
                // Her yeni sayfada yeni alt bilgi: görünür olunca bir kez yükler.
                key: ValueKey(page.items.length),
                error: page.loadMoreError,
                onLoadMore: onLoadMore,
              );
            }
            final item = page.items[i];
            return ItemCard(
              item: item,
              onTap: () => context.push(AppRoutes.itemDetail(item.id)),
            );
          },
        ),
      ),
    );
  }
}

/// Listenin sonu. ListView yalnızca ekrana yaklaşan öğeleri kurduğu için
/// bu öğenin kurulması "sona gelindi" demektir.
class _LoadMoreFooter extends StatefulWidget {
  const _LoadMoreFooter({
    super.key,
    required this.error,
    required this.onLoadMore,
  });

  final Object? error;
  final VoidCallback onLoadMore;

  @override
  State<_LoadMoreFooter> createState() => _LoadMoreFooterState();
}

class _LoadMoreFooterState extends State<_LoadMoreFooter> {
  @override
  void initState() {
    super.initState();
    if (widget.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onLoadMore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    if (error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final message = error is AppException
        ? error.message
        : 'Devamı yüklenemedi.';
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton.icon(
          onPressed: widget.onLoadMore,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar dene'),
        ),
      ],
    );
  }
}
