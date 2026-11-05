import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/app.dart';
import 'package:kampus_kayip_esya/app/providers/auth_provider.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repo, {
  Map<String, String> keychain = const {},
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  FlutterSecureStorage.setMockInitialValues(Map.of(keychain));
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      itemRepositoryProvider.overrideWithValue(
        MockItemRepository(latency: Duration.zero),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: KampusKayipEsyaApp(onboardingPrefs: prefs),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);
final _loginForm = find.widgetWithText(FilledButton, 'Giriş yap');
final _home = find.byType(NavigationBar);

Future<void> _login(
  WidgetTester tester, {
  String email = 'a@ankara.edu.tr',
}) async {
  await tester.enterText(_field('Okul e-postası'), email);
  await tester.enterText(_field('Şifre'), 'Sifre123!');
  await tester.tap(_loginForm);
  await tester.pumpAndSettle();
}

Future<void> _openRegisterAndSubmit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Kayıt ol'));
  await tester.pumpAndSettle();
  await tester.enterText(_field('Ad soyad'), 'Şeyma Kula');
  await tester.enterText(_field('Okul e-postası'), 'a@ankara.edu.tr');
  await tester.enterText(_field('Öğrenci / personel no'), '23291513');
  await tester.enterText(_field('Şifre'), 'Sifre123');
  await tester.enterText(_field('Şifre (tekrar)'), 'Sifre123');
  final submit = find.widgetWithText(FilledButton, 'Kayıt ol');
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

const _validKeychain = {
  'jwt': 'kayitli',
  'expiresAt': '2099-01-01T00:00:00.000Z',
};

void main() {
  group('otomatik giriş', () {
    testWidgets('kayıtlı oturumla giriş ekranı görünmeden ana sayfa açılır', (
      tester,
    ) async {
      await _pumpApp(tester, FakeAuthRepository(), keychain: _validKeychain);

      expect(_home, findsOneWidget);
      expect(_loginForm, findsNothing);
    });

    testWidgets('kontrol sürerken yükleniyor ekranı görünür', (tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_seen': true});
      FlutterSecureStorage.setMockInitialValues(Map.of(_validKeychain));
      final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            itemRepositoryProvider.overrideWithValue(
              MockItemRepository(latency: Duration.zero),
            ),
          ],
          child: KampusKayipEsyaApp(onboardingPrefs: prefs),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_home, findsNothing);
      expect(_loginForm, findsNothing);

      await tester.pumpAndSettle();
      expect(_home, findsOneWidget);
    });

    testWidgets('oturum yoksa giriş ekranı açılır', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());

      expect(_loginForm, findsOneWidget);
      expect(_home, findsNothing);
    });
  });

  group('yönlendirme', () {
    testWidgets('giriş başarılıysa ana sayfaya geçilir', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());

      await _login(tester);

      expect(_home, findsOneWidget);
    });

    testWidgets('kayıt başarılıysa ana sayfaya geçilir', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());

      await _openRegisterAndSubmit(tester);

      expect(_home, findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Kayıt Ol'), findsNothing);
    });

    testWidgets('oturum kapanınca (401) girişe dönülür', (tester) async {
      final c = await _pumpApp(
        tester,
        FakeAuthRepository(),
        keychain: _validKeychain,
      );
      expect(_home, findsOneWidget);

      await c.read(authStateProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(_loginForm, findsOneWidget);
      expect(_home, findsNothing);
    });
  });

  group('sunucu hataları', () {
    testWidgets('hatalı giriş mesajı görünür, ekranda kalınır', (tester) async {
      final repo = FakeAuthRepository()
        ..loginError = const ServerException(401, 'E-posta veya şifre hatalı.');
      await _pumpApp(tester, repo);

      await _login(tester);

      expect(find.text('E-posta veya şifre hatalı.'), findsOneWidget);
      expect(_loginForm, findsOneWidget);
      expect(_home, findsNothing);
    });

    testWidgets('alan hatası ilgili alanın altında, yazınca kaybolur', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..registerError = const ValidationException({
          'Email': ['Bu e-posta zaten kayıtlı.'],
          'StudentNo': ['Öğrenci numarası 8 haneli olmalı.'],
        });
      await _pumpApp(tester, repo);

      await _openRegisterAndSubmit(tester);

      Finder under(String label, String error) =>
          find.descendant(of: _field(label), matching: find.text(error));
      expect(
        under('Okul e-postası', 'Bu e-posta zaten kayıtlı.'),
        findsOneWidget,
      );
      expect(
        under('Öğrenci / personel no', 'Öğrenci numarası 8 haneli olmalı.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);

      await tester.enterText(_field('Okul e-postası'), 'b@ankara.edu.tr');
      await tester.pumpAndSettle();
      expect(find.text('Bu e-posta zaten kayıtlı.'), findsNothing);
      expect(find.text('Öğrenci numarası 8 haneli olmalı.'), findsOneWidget);
    });

    testWidgets('düzeltip yeniden gönderince hata kalkar, kayıt tamamlanır', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..registerError = const ValidationException({
          'Email': ['Bu e-posta zaten kayıtlı.'],
        });
      await _pumpApp(tester, repo);
      await _openRegisterAndSubmit(tester);
      expect(find.text('Bu e-posta zaten kayıtlı.'), findsOneWidget);

      repo.registerError = null;
      final submit = find.widgetWithText(FilledButton, 'Kayıt ol');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(_home, findsOneWidget);
    });

    testWidgets('alana bağlanamayan hata (Identity) kısa mesajla görünür', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..registerError = const ValidationException({
          'PasswordRequiresNonAlphanumeric': [
            'Şifre en az bir özel karakter içermeli.',
          ],
        });
      await _pumpApp(tester, repo);

      await _openRegisterAndSubmit(tester);

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Şifre en az bir özel karakter içermeli.'),
        ),
        findsOneWidget,
      );
    });
  });
}
