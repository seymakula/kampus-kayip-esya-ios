import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/app/router/app_router.dart';
import 'package:kampus_kayip_esya/app/router/app_routes.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:kampus_kayip_esya/features/search/filter_sheet.dart';
import 'package:kampus_kayip_esya/features/search/search_providers.dart';
import 'package:kampus_kayip_esya/features/search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock verideki "şimdi" (göreli tarihler buna göre üretildi).
final _mockNow = DateTime.utc(2026, 10, 30, 12);

Future<void> _pumpSearch(WidgetTester tester) async {
  // Filtre paneli ve uzun liste için yeterince yüksek ekran.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  final router = createAppRouter(
    onboardingPrefs: prefs,
    initialLocation: AppRoutes.search,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(
          MockItemRepository(latency: Duration.zero),
        ),
        clockProvider.overrideWithValue(() => _mockNow),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// Ekranda o an kurulu kartlar değil, aramanın yüklediği tüm sonuçlar.
List<Item> _results(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(SearchScreen)),
  );
  final filter = container.read(searchFilterProvider);
  return container.read(searchResultsProvider(filter)).value?.items ?? [];
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(searchDebounce);
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Filtrele'));
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String chip) async {
  final finder = find.widgetWithText(ChoiceChip, chip);
  // Panel uzun: alttaki bölümler kaydırılınca kurulur.
  await tester.scrollUntilVisible(
    finder,
    150,
    scrollable: find
        .descendant(
          of: find.byType(FilterSheet),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _applySheet(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Uygula'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('filtre yokken yayındaki tüm ilanlar listelenir', (tester) async {
    await _pumpSearch(tester);

    // İlk sayfa 10 ilan; 18 yayındaki ilanın kalanı kaydırınca gelir.
    expect(_results(tester), hasLength(10));
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(_results(tester), hasLength(18));
  });

  testWidgets('yazınca beklemeden sonra aranır', (tester) async {
    await _pumpSearch(tester);

    await tester.enterText(find.byType(TextField), 'cüzdan');
    await tester.pump(const Duration(milliseconds: 100));
    expect(_results(tester), hasLength(10), reason: 'henüz aranmadı');

    await tester.pump(searchDebounce);
    await tester.pumpAndSettle();
    expect(_results(tester).single.title, 'Kahverengi deri cüzdan');
  });

  testWidgets('sonuç yoksa boş durum, temizleyince liste geri gelir', (
    tester,
  ) async {
    await _pumpSearch(tester);

    await _type(tester, 'zürafa');
    expect(find.text('Sonuç bulunamadı'), findsOneWidget);

    await tester.tap(find.byTooltip('Temizle'));
    await tester.pumpAndSettle();
    expect(_results(tester), hasLength(10));
  });

  testWidgets('Kayıp / Bulunan seçimi', (tester) async {
    await _pumpSearch(tester);

    await tester.tap(find.text('Bulunan').last);
    await tester.pumpAndSettle();
    final found = _results(tester);
    expect(found, isNotEmpty);
    expect(found.every((i) => i.type == ItemType.found), isTrue);
  });

  testWidgets('kategori ve bina filtresi, çip ile kaldırma', (tester) async {
    await _pumpSearch(tester);

    await _openSheet(tester);
    await _choose(tester, 'Elektronik');
    await _choose(tester, 'Mühendislik Fakültesi');
    await _applySheet(tester);

    final results = _results(tester);
    expect(results, isNotEmpty);
    expect(
      results.every((i) => i.category.id == 1 && i.location.id == 1),
      isTrue,
    );
    // Rozet: 2 filtre seçili
    expect(find.text('2'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Elektronik'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'Elektronik'),
        matching: find.byIcon(Icons.clear),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'Elektronik'), findsNothing);
    expect(_results(tester).every((i) => i.location.id == 1), isTrue);
  });

  testWidgets('tarih filtresi olay tarihine göre süzer', (tester) async {
    await _pumpSearch(tester);

    await _openSheet(tester);
    await _choose(tester, 'Son 24 saat');
    await _applySheet(tester);

    final since = _mockNow.subtract(const Duration(days: 1));
    final results = _results(tester);
    expect(results, isNotEmpty);
    expect(results.every((i) => !i.eventDate.isBefore(since)), isTrue);
    expect(
      results.length,
      mockItems
          .where(
            (i) =>
                i.status == ItemStatus.published &&
                !i.eventDate.isBefore(since),
          )
          .length,
    );
  });

  testWidgets('Sıfırla paneldeki seçimleri temizler', (tester) async {
    await _pumpSearch(tester);

    await _openSheet(tester);
    await _choose(tester, 'Elektronik');
    await _applySheet(tester);
    expect(find.byType(InputChip), findsOneWidget);

    await _openSheet(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sıfırla'));
    await _applySheet(tester);
    expect(find.byType(InputChip), findsNothing);
    expect(_results(tester), hasLength(10));
  });

  testWidgets('sekme değişince arama korunur', (tester) async {
    await _pumpSearch(tester);
    await _type(tester, 'cüzdan');

    await tester.tap(find.text('Ana Sayfa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ara'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'cüzdan'), findsOneWidget);
    expect(_results(tester), hasLength(1));
  });
}
