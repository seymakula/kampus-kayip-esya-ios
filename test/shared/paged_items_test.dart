import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/features/home/item_list_provider.dart';
import 'package:kampus_kayip_esya/shared/paging/paged_items.dart';

import '../helpers/fake_item_repository.dart';

void main() {
  late FakeItemRepository repo;
  late ProviderContainer c;
  final provider = itemListProvider(ItemType.lost);

  setUp(() {
    repo = FakeItemRepository(count: 25);
    c = ProviderContainer(
      overrides: [itemRepositoryProvider.overrideWithValue(repo)],
      retry: (_, _) => null,
    );
    addTearDown(c.dispose);
  });

  Future<PagedItems> first() => c.read(provider.future);
  PagedItems current() => c.read(provider).value!;

  test('ilk sayfa 10 ilan, devamı var', () async {
    final page = await first();
    expect(page.items, hasLength(PagedItemsNotifier.pageSize));
    expect(page.page, 1);
    expect(page.hasMore, isTrue);
  });

  test('loadMore sırayla sayfaları ekler, son sayfada durur', () async {
    await first();
    await c.read(provider.notifier).loadMore();
    expect(current().items, hasLength(20));

    await c.read(provider.notifier).loadMore();
    expect(current().items, hasLength(25));
    expect(current().hasMore, isFalse);

    await c.read(provider.notifier).loadMore();
    expect(repo.requestedPages, [1, 2, 3]);
    expect(current().items.map((i) => i.title).last, 'İlan 25');
  });

  test('aynı anda iki loadMore tek istek atar', () async {
    await first();
    final notifier = c.read(provider.notifier);
    await Future.wait([notifier.loadMore(), notifier.loadMore()]);
    expect(repo.requestedPages, [1, 2]);
  });

  test('sonraki sayfa hata verirse liste kalır, tekrar denenebilir', () async {
    await first();
    repo.failingPages.add(2);

    await c.read(provider.notifier).loadMore();
    expect(current().items, hasLength(10));
    expect(current().loadMoreError, isA<NetworkException>());
    expect(c.read(provider).hasError, isFalse);

    repo.failingPages.clear();
    await c.read(provider.notifier).loadMore();
    expect(current().items, hasLength(20));
    expect(current().loadMoreError, isNull);
  });

  test('refresh ilk sayfaya döner', () async {
    await first();
    await c.read(provider.notifier).loadMore();
    expect(current().items, hasLength(20));

    await c.read(provider.notifier).refresh();
    expect(current().items, hasLength(10));
    expect(current().page, 1);
  });

  test('refresh hatası fırlatılmaz, durumda görünür', () async {
    await first();
    repo.failingPages.add(1);

    await c.read(provider.notifier).refresh();
    expect(c.read(provider).error, isA<NetworkException>());
  });
}
