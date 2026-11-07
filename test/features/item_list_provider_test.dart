import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/api_item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/home/item_list_provider.dart';

ProviderContainer _container([ItemRepository? repo]) {
  final c = ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWithValue(
        repo ?? MockItemRepository(latency: Duration.zero),
      ),
    ],
    retry: (_, _) => null,
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ana sayfa listesi repository\'den Riverpod üzerinden gelir', () async {
    final c = _container();
    final all = (await c.read(itemListProvider(null).future)).items;
    final lost = (await c.read(itemListProvider(ItemType.lost).future)).items;

    expect(all, isNotEmpty);
    expect(lost, isNotEmpty);
    expect(lost.every((i) => i.type == ItemType.lost), isTrue);
  });

  test('varsayılan itemRepositoryProvider USE_MOCK yoksa API kullanır', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(itemRepositoryProvider), isA<ApiItemRepository>());
  });
}
