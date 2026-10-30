import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/app/router/app_router.dart';
import 'package:kampus_kayip_esya/app/router/app_routes.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<OnboardingPrefs> _prefs({bool seen = true}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': seen});
  return OnboardingPrefs(await SharedPreferences.getInstance());
}

Widget _scoped(Widget child) => ProviderScope(
  overrides: [
    itemRepositoryProvider.overrideWithValue(
      MockItemRepository(latency: Duration.zero),
    ),
  ],
  child: child,
);

Future<void> _pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  bool seen = true,
}) async {
  final router = createAppRouter(
    onboardingPrefs: await _prefs(seen: seen),
    initialLocation: initialLocation,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _scoped(MaterialApp.router(theme: AppTheme.light, routerConfig: router)),
  );
  await tester.pumpAndSettle();
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Finder _appBarTitle(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

void main() {
  testWidgets('alt menüde 5 sekme var, ana sayfa seçili açılıyor', (
    tester,
  ) async {
    await _pumpApp(tester);

    for (final label in [
      'Ana Sayfa',
      'Ara',
      'Yeni İlan',
      'Mesajlar',
      'Profil',
    ]) {
      expect(_tab(label), findsOneWidget);
    }
    expect(_appBarTitle('Kampüs Kayıp Eşya'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  testWidgets('sekmelere dokununca ilgili ekran açılıyor', (tester) async {
    await _pumpApp(tester);

    const expected = {
      'Ara': 'Ara',
      'Yeni İlan': 'Yeni İlan',
      'Mesajlar': 'Mesajlar',
      'Profil': 'Profil',
      'Ana Sayfa': 'Kampüs Kayıp Eşya',
    };
    for (final MapEntry(key: tab, value: title) in expected.entries) {
      await tester.tap(_tab(tab));
      await tester.pumpAndSettle();
      expect(_appBarTitle(title), findsOneWidget, reason: '$tab sekmesi');
    }
  });

  testWidgets('zil bildirimler sayfasını alt menünün üstünde açar', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byTooltip('Bildirimler'));
    await tester.pumpAndSettle();
    expect(_appBarTitle('Bildirimler'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(_appBarTitle('Kampüs Kayıp Eşya'), findsOneWidget);
  });

  testWidgets('ilan detayı yolu id parametresini okur', (tester) async {
    await _pumpApp(tester, initialLocation: AppRoutes.itemDetail(7));

    expect(_appBarTitle('İlan Detayı'), findsOneWidget);
    expect(find.text('İlan #7'), findsOneWidget);
  });

  testWidgets('tanıtım görülmediyse her yol tanıtıma yönlenir', (tester) async {
    await _pumpApp(tester, seen: false, initialLocation: AppRoutes.profile);

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('koyu temada da taşma yok (iPhone SE)', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final router = createAppRouter(onboardingPrefs: await _prefs());
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _scoped(MaterialApp.router(theme: AppTheme.dark, routerConfig: router)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
