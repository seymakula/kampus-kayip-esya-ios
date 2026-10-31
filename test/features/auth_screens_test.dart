import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/app/router/app_router.dart';
import 'package:kampus_kayip_esya/app/router/app_routes.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/auth/widgets/auth_submit.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpAt(
  WidgetTester tester,
  String location, {
  bool onboardingSeen = true,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': onboardingSeen});
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  final router = createAppRouter(
    onboardingPrefs: prefs,
    initialLocation: location,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(
          MockItemRepository(latency: Duration.zero),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

/// Sahte giriş beklemesini geçer.
Future<void> _waitSubmit(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(mockAuthDelay);
  await tester.pumpAndSettle();
}

void main() {
  group('Giriş', () {
    testWidgets('boş gönderimde alan hataları görünür, gezinme olmaz', (
      tester,
    ) async {
      await _pumpAt(tester, AppRoutes.login);

      await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
      await tester.pumpAndSettle();

      expect(find.text('E-posta adresini gir.'), findsOneWidget);
      expect(find.text('Şifreni gir.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('okul dışı e-posta reddedilir', (tester) async {
      await _pumpAt(tester, AppRoutes.login);

      await tester.enterText(_field('Okul e-postası'), 'baris@gmail.com');
      await tester.enterText(_field('Şifre'), 'sifre123');
      await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Okul e-postanı'), findsOneWidget);
    });

    testWidgets('geçerli bilgilerle ana sayfaya geçilir', (tester) async {
      await _pumpAt(tester, AppRoutes.login);

      await tester.enterText(
        _field('Okul e-postası'),
        'baris.coskun@ogrenci.ankara.edu.tr',
      );
      await tester.enterText(_field('Şifre'), 'sifre123');
      await tester.tap(find.widgetWithText(FilledButton, 'Giriş yap'));
      await _waitSubmit(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Kampüs Kayıp Eşya'), findsOneWidget);
    });

    testWidgets('şifre göster / gizle', (tester) async {
      await _pumpAt(tester, AppRoutes.login);

      bool obscured() => tester
          .widget<EditableText>(
            find.descendant(
              of: _field('Şifre'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;

      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Şifreyi göster'));
      await tester.pump();
      expect(obscured(), isFalse);
    });

    testWidgets('"Kayıt ol" kayıt ekranını açar, geri ile dönülür', (
      tester,
    ) async {
      await _pumpAt(tester, AppRoutes.login);

      await tester.tap(find.widgetWithText(TextButton, 'Kayıt ol'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Kayıt Ol'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Giriş yap'), findsOneWidget);
    });
  });

  group('Kayıt', () {
    Future<void> fill(
      WidgetTester tester, {
      String name = 'Barış Coşkun',
      String email = 'baris.coskun@ogrenci.ankara.edu.tr',
      String no = '23291721',
      String password = 'sifre123',
      String again = 'sifre123',
    }) async {
      await tester.enterText(_field('Ad soyad'), name);
      await tester.enterText(_field('Okul e-postası'), email);
      await tester.enterText(_field('Öğrenci / personel no'), no);
      await tester.enterText(_field('Şifre'), password);
      await tester.enterText(_field('Şifre (tekrar)'), again);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Kayıt ol'));
      await tester.tap(find.widgetWithText(FilledButton, 'Kayıt ol'));
    }

    testWidgets('şifreler eşleşmezse hata', (tester) async {
      await _pumpAt(tester, AppRoutes.register);

      await fill(tester, again: 'sifre999');
      await tester.pumpAndSettle();

      expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('zayıf şifre ve hatalı numara reddedilir', (tester) async {
      await _pumpAt(tester, AppRoutes.register);

      await fill(tester, no: '12ab', password: 'kisa', again: 'kisa');
      await tester.pumpAndSettle();

      expect(find.textContaining('rakamlardan'), findsOneWidget);
      expect(find.textContaining('en az 8'), findsOneWidget);
    });

    testWidgets('geçerli bilgilerle ana sayfaya geçilir', (tester) async {
      await _pumpAt(tester, AppRoutes.register);

      await fill(tester);
      await _waitSubmit(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('küçük ekranda (iPhone SE) taşma yok', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await _pumpAt(tester, AppRoutes.register);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('tanıtım bitince giriş ekranı açılır', (tester) async {
    await _pumpAt(tester, AppRoutes.home, onboardingSeen: false);

    await tester.tap(find.text('Atla'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Giriş yap'), findsOneWidget);
  });
}
