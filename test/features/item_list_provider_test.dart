import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/auth_provider.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/home/item_list_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    final all = await c.read(itemListProvider(null).future);
    final lost = await c.read(itemListProvider(ItemType.lost).future);

    expect(all, isNotEmpty);
    expect(lost, isNotEmpty);
    expect(lost.every((i) => i.type == ItemType.lost), isTrue);
  });

  test('varsayılan itemRepositoryProvider mock döner', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(itemRepositoryProvider), isA<MockItemRepository>());
  });

  test('signOut token\'ı siler ve oturumu kapatır', () async {
    FlutterSecureStorage.setMockInitialValues({'jwt': 'abc', 'expiresAt': 'x'});
    final c = _container();
    expect(c.read(authStateProvider).isLoggedIn, isTrue);

    await c.read(authStateProvider.notifier).signOut();

    expect(c.read(authStateProvider).isLoggedIn, isFalse);
    expect(await c.read(secureStorageProvider).read(key: 'jwt'), isNull);
  });
}
