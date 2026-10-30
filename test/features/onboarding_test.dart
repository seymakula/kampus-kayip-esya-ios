import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:kampus_kayip_esya/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<OnboardingPrefs> _prefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return OnboardingPrefs(await SharedPreferences.getInstance());
}

Future<void> _pumpApp(WidgetTester tester, OnboardingPrefs prefs) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider.overrideWithValue(
            MockItemRepository(latency: Duration.zero),
          ),
        ],
        child: KampusKayipEsyaApp(onboardingPrefs: prefs),
      ),
    );

void main() {
  testWidgets(
    'ilk açılışta tanıtım görünüyor, Atla ile geçiliyor ve kaydediliyor',
    (tester) async {
      final prefs = await _prefs();
      await _pumpApp(tester, prefs);

      expect(find.text('İlan aç'), findsOneWidget);
      await tester.tap(find.text('Atla'));
      await tester.pumpAndSettle();

      expect(find.text('İlan aç'), findsNothing);
      expect(prefs.seen, isTrue);
    },
  );

  testWidgets('ikinci açılışta tanıtım görünmüyor', (tester) async {
    final prefs = await _prefs({'onboarding_seen': true});
    await _pumpApp(tester, prefs);

    await tester.pumpAndSettle();

    expect(find.text('İlan aç'), findsNothing);
    expect(find.text('Atla'), findsNothing);
  });

  testWidgets('İleri ile 3 sayfa gezilir, son sayfada Başla', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(tester, prefs);

    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    expect(find.text('Eşleş'), findsOneWidget);

    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    expect(find.text('Güvenle teslim al'), findsOneWidget);
    expect(find.text('Başla'), findsOneWidget);

    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();
    expect(prefs.seen, isTrue);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('küçük ekranda (iPhone SE) taşma yok', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final prefs = await _prefs();
    await _pumpApp(tester, prefs);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
