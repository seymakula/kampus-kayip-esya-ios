import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/app/router/app_router.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/item_detail/item_detail_screen.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:kampus_kayip_esya/shared/widgets/item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_item_repository.dart';

/// Belirli bir türde hiç ilan döndürmeyen repository (boş durum testi).
class _EmptyFoundRepository extends MockItemRepository {
  _EmptyFoundRepository() : super(latency: Duration.zero);

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
    if (type == ItemType.found) {
      return PagedResult(
        items: const [],
        page: page,
        pageSize: pageSize,
        totalCount: 0,
      );
    }
    return super.getItems(type: type, page: page, pageSize: pageSize);
  }
}

Future<void> _pumpHome(WidgetTester tester, {ItemRepository? repo}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  final router = createAppRouter(onboardingPrefs: prefs);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(
          repo ?? MockItemRepository(latency: Duration.zero),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

List<Item> _visibleItems(WidgetTester tester) => tester
    .widgetList<ItemCard>(find.byType(ItemCard))
    .map((c) => c.item)
    .toList();

void main() {
  testWidgets('Kayıp sekmesi açık gelir ve yalnızca kayıp ilanlar listelenir', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.widgetWithText(Tab, 'Kayıp'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Bulunan'), findsOneWidget);

    final items = _visibleItems(tester);
    expect(items, isNotEmpty);
    expect(items.every((i) => i.type == ItemType.lost), isTrue);
  });

  testWidgets('Bulunan sekmesine geçince bulunan ilanlar listelenir', (
    tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.widgetWithText(Tab, 'Bulunan'));
    await tester.pumpAndSettle();

    final items = _visibleItems(tester);
    expect(items, isNotEmpty);
    expect(items.every((i) => i.type == ItemType.found), isTrue);
  });

  testWidgets('karta dokununca ilan detayı açılır', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532); // iPhone boyutu
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pumpHome(tester);

    final first = _visibleItems(tester).first;
    await tester.tap(find.text(first.title));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(ItemDetailScreen),
        matching: find.text(first.title),
      ),
      findsOneWidget,
    );
  });

  testWidgets('ilan yoksa boş durum gösterilir', (tester) async {
    await _pumpHome(tester, repo: _EmptyFoundRepository());

    await tester.tap(find.widgetWithText(Tab, 'Bulunan'));
    await tester.pumpAndSettle();

    expect(find.text('Bulunan ilanı yok'), findsOneWidget);
  });

  testWidgets('küçük ekranda (iPhone SE) kartlarda taşma yok', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pumpHome(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sona kaydırınca sonraki sayfa yüklenir', (tester) async {
    final repo = FakeItemRepository(count: 25);
    await _pumpHome(tester, repo: repo);
    expect(repo.requestedPages, [1]);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(repo.requestedPages, [1, 2]);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(repo.requestedPages, [1, 2, 3]);
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('İlan 25'), findsOneWidget);
    // Son sayfadan sonra yükleniyor göstergesi kalmaz.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('sonraki sayfa hatasında Tekrar dene', (tester) async {
    final repo = FakeItemRepository(count: 25)..failingPages.add(2);
    await _pumpHome(tester, repo: repo);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('Sunucuya bağlanılamadı.'), findsOneWidget);
    expect(_visibleItems(tester), isNotEmpty);

    repo.failingPages.clear();
    await tester.tap(find.widgetWithText(TextButton, 'Tekrar dene'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('İlan 20'), findsOneWidget);
  });
}
