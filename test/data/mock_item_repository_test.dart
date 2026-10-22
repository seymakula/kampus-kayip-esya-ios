import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = MockItemRepository(latency: Duration.zero);

  test('mock repository\'den liste çekilebiliyor', () async {
    final res = await repo.getItems();
    expect(res.items, isNotEmpty);
    expect(res.items.length, 10);
    expect(res.totalCount, 18); // onay bekleyen + teslim edilen hariç
  });

  test('yalnızca yayındaki ilanlar, en yeni önce', () async {
    final res = await repo.getItems(pageSize: 100);
    expect(res.items.every((i) => i.status == ItemStatus.published), isTrue);
    for (var i = 1; i < res.items.length; i++) {
      expect(
        res.items[i - 1].createdAt.isAfter(res.items[i].createdAt) ||
            res.items[i - 1].createdAt == res.items[i].createdAt,
        isTrue,
      );
    }
  });

  test('tür, kategori ve arama filtresi', () async {
    final lost = await repo.getItems(type: ItemType.lost, pageSize: 100);
    expect(lost.items.every((i) => i.type == ItemType.lost), isTrue);

    final elektronik = await repo.getItems(categoryId: 1, pageSize: 100);
    expect(elektronik.items.every((i) => i.category.id == 1), isTrue);

    final q = await repo.getItems(query: 'termos');
    expect(q.items.single.id, 5);
  });

  test('sayfalama totalCount\'a ulaşınca biter', () async {
    final p2 = await repo.getItems(page: 2);
    expect(p2.items.length, 8);
    expect(p2.hasMore, isFalse);
  });

  test('getItem ve bilinmeyen id', () async {
    expect((await repo.getItem(3)).title, 'AirPods kutusu');
    expect(() => repo.getItem(999), throwsStateError);
  });

  test('her mock fotoğraf asset olarak mevcut', () async {
    for (final photo in mockItems.expand((i) => i.photos)) {
      expect(photo.isAsset, isTrue);
      final data = await rootBundle.load(photo.url);
      expect(data.lengthInBytes, greaterThan(0), reason: photo.url);
    }
  });
}
