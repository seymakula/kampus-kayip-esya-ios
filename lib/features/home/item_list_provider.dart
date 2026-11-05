import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../data/models/models.dart';
import '../../shared/paging/paged_items.dart';

/// Ana sayfa ilan listesi. Ekran `ref.watch(itemListProvider(type))` ile
/// `AsyncValue<PagedItems>` alır; sonraki sayfa için `loadMore()`.
///
/// `type == null` → tüm ilanlar; Kayıp / Bulunan sekmeleri
/// `ItemType.lost` / `ItemType.found` ile çağırır.
class ItemListNotifier extends PagedItemsNotifier {
  ItemListNotifier(this.type);

  final ItemType? type;

  @override
  Future<PagedResult<Item>> fetchPage(int page) => ref
      .read(itemRepositoryProvider)
      .getItems(type: type, page: page, pageSize: PagedItemsNotifier.pageSize);
}

final itemListProvider =
    AsyncNotifierProvider.family<ItemListNotifier, PagedItems, ItemType?>(
      ItemListNotifier.new,
    );
