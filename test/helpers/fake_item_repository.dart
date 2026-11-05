import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';

/// Sayfalama testleri için çok sayıda ilan döndüren, istenen sayfada hata
/// verebilen repository. Kategori ve bina listeleri mock veriden gelir.
class FakeItemRepository extends MockItemRepository {
  FakeItemRepository({int count = 25, ItemType type = ItemType.lost})
    : items = [
        for (var i = 1; i <= count; i++)
          mockItems.first.copyWith(id: 1000 + i, title: 'İlan $i', type: type),
      ],
      super(latency: Duration.zero);

  final List<Item> items;

  /// Bu sayfalar istenince [NetworkException] fırlatılır.
  final Set<int> failingPages = {};

  final List<int> requestedPages = [];

  @override
  Future<PagedResult<Item>> getItems({
    ItemType? type,
    String? query,
    int? categoryId,
    int? locationId,
    DateTime? since,
    int page = 1,
    int pageSize = 10,
  }) async {
    requestedPages.add(page);
    if (failingPages.contains(page)) {
      throw const NetworkException('Sunucuya bağlanılamadı.');
    }
    final filtered = items.where((i) => type == null || i.type == type);
    return PagedResult(
      items: filtered.skip((page - 1) * pageSize).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: filtered.length,
    );
  }
}
