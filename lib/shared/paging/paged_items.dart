import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';

/// Sonsuz kaydırmalı listenin durumu: o ana kadar yüklenen ilanlar ve
/// sonraki sayfanın durumu.
class PagedItems {
  const PagedItems({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PagedItems.first(PagedResult<Item> result) => PagedItems(
    items: result.items,
    page: result.page,
    hasMore: result.hasMore && result.items.isNotEmpty,
  );

  final List<Item> items;

  /// Son yüklenen sayfa (1'den başlar).
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// Sonraki sayfa yüklenemediyse hata; liste ekranda kalır.
  final Object? loadMoreError;

  PagedItems _loadingMore() => PagedItems(
    items: items,
    page: page,
    hasMore: hasMore,
    isLoadingMore: true,
  );

  PagedItems _failed(Object error) => PagedItems(
    items: items,
    page: page,
    hasMore: hasMore,
    loadMoreError: error,
  );

  PagedItems _append(PagedResult<Item> next) {
    // Yeni ilan eklenince sayfalar kayabilir; aynı ilan iki kez görünmesin.
    final seen = {for (final i in items) i.id};
    return PagedItems(
      items: [...items, ...next.items.where((i) => !seen.contains(i.id))],
      page: next.page,
      hasMore: next.hasMore && next.items.isNotEmpty,
    );
  }
}

/// Sayfalı ilan listelerinin ortak mantığı. Alt sınıf yalnızca
/// [fetchPage]'i yazar: ana sayfa sekmeleri, arama sonuçları, "İlanlarım".
abstract class PagedItemsNotifier extends AsyncNotifier<PagedItems> {
  static const pageSize = 10;

  Future<PagedResult<Item>> fetchPage(int page);

  @override
  Future<PagedItems> build() async => PagedItems.first(await fetchPage(1));

  /// Aşağı çekip yenileme: ilk sayfadan yeniden yükler. Hata olursa
  /// [state]'e yazılır, burada fırlatılmaz.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {}
  }

  /// Listenin sonuna gelinince çağrılır. Zaten yükleniyorsa, sayfa
  /// kalmadıysa veya ilk sayfa hâlâ yükleniyorsa bir şey yapmaz.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    final loading = current._loadingMore();
    state = AsyncData(loading);
    try {
      final next = await fetchPage(current.page + 1);
      // Bu arada yenilendiyse eski sayfayı yeni listeye ekleme.
      if (!ref.mounted || !identical(state.value, loading)) return;
      state = AsyncData(current._append(next));
    } catch (e) {
      if (!ref.mounted || !identical(state.value, loading)) return;
      state = AsyncData(current._failed(e));
    }
  }
}
