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
    DateTime? since,
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
        .where((i) => since == null || !i.eventDate.isBefore(since))
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

  int _nextId = 1000;

  @override
  Future<Item> createItem(NewItem item) async {
    await Future<void>.delayed(latency);
    final now = DateTime.now().toUtc();
    return Item(
      id: ++_nextId,
      type: item.type,
      status: ItemStatus.pending,
      title: item.title,
      description: item.description,
      category: mockCategories.firstWhere((c) => c.id == item.categoryId),
      location: mockLocations.firstWhere((l) => l.id == item.locationId),
      eventDate: item.eventDate,
      createdAt: now,
      isOwner: true,
      ownerName: 'Şeyma K.',
      verificationQuestion: item.verificationQuestion,
    );
  }

  @override
  Future<Item> uploadPhotos(
    int itemId,
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  }) async {
    for (var i = 1; i <= 4; i++) {
      await Future<void>.delayed(latency ~/ 4);
      onProgress?.call(i / 4);
    }
    return Item(
      id: itemId,
      type: ItemType.found,
      status: ItemStatus.pending,
      title: '',
      category: mockCategories.first,
      location: mockLocations.first,
      eventDate: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      isOwner: true,
      photos: [
        for (final (i, path) in filePaths.indexed)
          ItemPhoto(id: i, url: 'file://$path', sortOrder: i),
      ],
    );
  }
}
