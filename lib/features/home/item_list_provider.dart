import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/auth_provider.dart';
import '../../app/providers/core_providers.dart';
import '../../data/models/models.dart';
import '../../shared/paging/paged_items.dart';
import '../search/search_providers.dart';

/// Ana sayfa ilan listesi. Ekran `ref.watch(itemListProvider(type))` ile
/// `AsyncValue<PagedItems>` alır; sonraki sayfa için `loadMore()`.
///
/// `type == null` → tüm ilanlar; Kayıp / Bulunan sekmeleri
/// `ItemType.lost` / `ItemType.found` ile çağırır.
class ItemListNotifier extends PagedItemsNotifier {
  ItemListNotifier(this.type);

  final ItemType? type;

  @override
  Future<PagedItems> build() {
    // Çıkış veya başka kullanıcıyla giriş olunca liste baştan yüklenir.
    ref.watch(authStateProvider.select((s) => s.user?.id));
    // Ana sayfa filtresi değişince liste ilk sayfadan yeniden yüklenir.
    ref.watch(homeFilterProvider);
    return super.build();
  }

  @override
  Future<PagedResult<Item>> fetchPage(int page) {
    final filter = ref.read(homeFilterProvider);
    return ref
        .read(itemRepositoryProvider)
        .getItems(
          type: type,
          categoryId: filter.categoryId,
          locationId: filter.locationId,
          since: filter.range.since(ref.read(clockProvider)()),
          page: page,
          pageSize: PagedItemsNotifier.pageSize,
        );
  }
}

final itemListProvider =
    AsyncNotifierProvider.family<ItemListNotifier, PagedItems, ItemType?>(
      ItemListNotifier.new,
    );
