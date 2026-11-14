import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../data/models/models.dart';

/// Tek ilan. Detay ekranı ve üstüne açılan galeri aynı sonucu paylaşır;
/// ikisi de kapanınca bellekten atılır.
final itemDetailProvider = FutureProvider.autoDispose.family<Item, int>(
  (ref, id) => ref.watch(itemRepositoryProvider).getItem(id),
);

/// Detaydaki fotoğraf ile galerideki aynı fotoğrafın geçiş animasyonu için.
String itemPhotoHeroTag(int itemId, ItemPhoto photo) =>
    'item-$itemId-photo-${photo.id}';
