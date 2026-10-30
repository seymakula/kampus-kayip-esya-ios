import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../data/models/models.dart';

/// Ana sayfa ilan listesi. Diğer liste ekranları bu kalıbı kopyalar:
/// `build` ilk sayfayı yükler, ekran `ref.watch(itemListProvider(type))`
/// ile `AsyncValue<List<Item>>` alır.
///
/// `type == null` → tüm ilanlar; Kayıp / Bulunan sekmeleri
/// `ItemType.lost` / `ItemType.found` ile çağırır.
class ItemListNotifier extends AsyncNotifier<List<Item>> {
  ItemListNotifier(this.type);

  final ItemType? type;

  @override
  Future<List<Item>> build() async {
    final res = await ref.read(itemRepositoryProvider).getItems(type: type);
    return res.items;
  }

  /// Aşağı çekip yenileme ve "Tekrar dene" için.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final itemListProvider =
    AsyncNotifierProvider.family<ItemListNotifier, List<Item>, ItemType?>(
      ItemListNotifier.new,
    );
