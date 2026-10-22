import '../mock/mock_data.dart';
import '../models/models.dart';
import 'item_repository.dart';

class MockItemRepository implements ItemRepository {
  MockItemRepository({this.latency = const Duration(milliseconds: 400)});

  /// Yükleniyor durumlarının ekranda görülebilmesi için yapay gecikme.
  final Duration latency;

  @override
  Future<PagedResult<Item>> getItems({
    ItemType? type,
    String? query,
    int? categoryId,
    int? locationId,
    int page = 1,
    int pageSize = 10,
  }) async {
    await Future<void>.delayed(latency);
    final q = query?.trim().toLowerCase();
    final filtered = mockItems
        .where((i) => i.status == ItemStatus.published)
        .where((i) => type == null || i.type == type)
        .where((i) => categoryId == null || i.category.id == categoryId)
        .where((i) => locationId == null || i.location.id == locationId)
        .where((i) =>
            q == null ||
            q.isEmpty ||
            i.title.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final start = (page - 1) * pageSize;
    return PagedResult(
      items: filtered.skip(start).take(pageSize).toList(),
      page: page,
      pageSize: pageSize,
      totalCount: filtered.length,
    );
  }

  @override
  Future<Item> getItem(int id) async {
    await Future<void>.delayed(latency);
    return mockItems.firstWhere(
      (i) => i.id == id,
      orElse: () => throw StateError('İlan bulunamadı: $id'),
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future<void>.delayed(latency);
    return mockCategories;
  }

  @override
  Future<List<Location>> getLocations() async {
    await Future<void>.delayed(latency);
    return mockLocations;
  }
}
