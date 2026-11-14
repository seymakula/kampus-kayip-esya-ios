import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/app.dart';
import 'package:kampus_kayip_esya/app/config.dart';
import 'package:kampus_kayip_esya/app/providers/auth_provider.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/features/home/item_list_provider.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:kampus_kayip_esya/features/profile/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_item_repository.dart';

const _keychain = {'jwt': 'kayitli', 'expiresAt': '2099-01-01T00:00:00.000Z'};

class _Kullanici extends FakeAuthRepository {
  _Kullanici(this.user);

  User user;

  @override
  Future<User> me() async {
    await super.me();
    return user;
  }
}

const _seyma = User(
  id: 'u1',
  fullName: 'Şeyma Kula',
  email: 'seyma.kula@ogrenci.ankara.edu.tr',
  studentNo: '23291513',
);

/// Giriş yapılmış uygulama, Profil sekmesi açık.
Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  FakeAuthRepository? auth,
  FakeItemRepository? items,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  FlutterSecureStorage.setMockInitialValues(Map.of(_keychain));
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWithValue(auth ?? _Kullanici(_seyma)),
      itemRepositoryProvider.overrideWithValue(items ?? FakeItemRepository()),
    ],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: KampusKayipEsyaApp(onboardingPrefs: OnboardingPrefs(prefs)),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Profil'),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

final _loginButton = find.widgetWithText(FilledButton, 'Giriş yap');

void main() {
  group('Profil', () {
    testWidgets('ad, e-posta ve öğrenci no görünür', (tester) async {
      await _pumpProfile(tester);

      expect(find.text('Şeyma Kula'), findsOneWidget);
      expect(find.text('seyma.kula@ogrenci.ankara.edu.tr'), findsOneWidget);
      expect(find.text('Öğrenci no: 23291513'), findsOneWidget);
      expect(find.text('ŞK'), findsOneWidget);
    });

    testWidgets('öğrenci no yoksa satır görünmez (personel)', (tester) async {
      await _pumpProfile(
        tester,
        auth: _Kullanici(
          const User(
            id: 'g1',
            fullName: 'Test Görevlisi',
            email: 'gorevli@ankara.edu.tr',
          ),
        ),
      );

      expect(find.text('Test Görevlisi'), findsOneWidget);
      expect(find.textContaining('Öğrenci no'), findsNothing);
    });

    testWidgets('aşağı çekince bilgiler sunucudan yenilenir', (tester) async {
      final auth = _Kullanici(_seyma);
      await _pumpProfile(tester, auth: auth);
      final callsBefore = auth.meCalls;
      auth.user = _seyma.copyWith(fullName: 'Şeyma K. Kula');

      await tester.fling(find.text('Ayarlar'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(auth.meCalls, callsBefore + 1);
      expect(find.text('Şeyma K. Kula'), findsOneWidget);
    });

    testWidgets('yenileme hatası kısa mesajla görünür', (tester) async {
      final auth = _Kullanici(_seyma);
      await _pumpProfile(tester, auth: auth);
      auth.meError = const NetworkException('Sunucuya bağlanılamadı.');

      await tester.fling(find.text('Ayarlar'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Sunucuya bağlanılamadı.'), findsOneWidget);
      expect(find.text('Şeyma Kula'), findsOneWidget);
    });

    testWidgets('İlanlarım ve Taleplerim şimdilik pasif', (tester) async {
      await _pumpProfile(tester);

      for (final title in ['İlanlarım', 'Taleplerim']) {
        final tile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, title),
        );
        expect(tile.enabled, isFalse, reason: title);
      }
    });

    testWidgets('Ayarlar alt menünün üstünde açılır', (tester) async {
      await _pumpProfile(tester);

      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Ayarlar'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('Çıkış', () {
    testWidgets('iptal edilirse oturum açık kalır', (tester) async {
      final c = await _pumpProfile(tester);

      await tester.tap(find.text('Çıkış yap'));
      await tester.pumpAndSettle();
      expect(find.text('Çıkış yapılsın mı?'), findsOneWidget);

      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      expect(c.read(authStateProvider).isLoggedIn, isTrue);
      expect(find.text('Şeyma Kula'), findsOneWidget);
    });

    testWidgets('onaylanınca Keychain temizlenir ve girişe dönülür', (
      tester,
    ) async {
      final c = await _pumpProfile(tester);

      await tester.tap(find.text('Çıkış yap'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Çıkış yap'),
        ),
      );
      await tester.pumpAndSettle();

      expect(_loginButton, findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final storage = c.read(secureStorageProvider);
      expect(await storage.read(key: 'jwt'), isNull);
      expect(await storage.read(key: 'expiresAt'), isNull);
    });

    testWidgets('çıkış ve yeniden girişte ilan listesi baştan yüklenir', (
      tester,
    ) async {
      final items = FakeItemRepository();
      final c = await _pumpProfile(tester, items: items);
      await c.read(itemListProvider(ItemType.lost).future);
      final before = items.requestedPages.length;

      await c.read(authStateProvider.notifier).signOut();
      await tester.pumpAndSettle();
      await c
          .read(authStateProvider.notifier)
          .login(email: 'a@ankara.edu.tr', password: 'x');
      await tester.pumpAndSettle();
      await c.read(itemListProvider(ItemType.lost).future);

      expect(items.requestedPages.length, greaterThan(before));
    });
  });

  group('Ayarlar', () {
    Future<ProviderContainer> openSettings(WidgetTester tester) async {
      final c = await _pumpProfile(tester);
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      return c;
    }

    Finder apiField() => find.widgetWithText(TextFormField, 'API adresi');

    testWidgets('tema seçimi yer tutucu: Sistem seçili, değiştirilemez', (
      tester,
    ) async {
      await openSettings(tester);

      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, {ThemeMode.system});
      expect(segmented.onSelectionChanged, isNull);
    });

    testWidgets('geçersiz adres reddedilir', (tester) async {
      final c = await openSettings(tester);

      await tester.enterText(apiField(), 'localhost:5080');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Geçerli bir adres gir'), findsOneWidget);
      expect(c.read(apiBaseUrlProvider), apiBase);
    });

    testWidgets('kaydedilen adres istemciye ve kalıcı ayara yansır', (
      tester,
    ) async {
      final c = await openSettings(tester);

      await tester.enterText(apiField(), ' http://192.168.1.20:5080/ ');
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('API adresi kaydedildi.'), findsOneWidget);
      expect(c.read(apiBaseUrlProvider), 'http://192.168.1.20:5080');
      expect(
        c.read(apiClientProvider).dio.options.baseUrl,
        'http://192.168.1.20:5080',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('api_base_override'), 'http://192.168.1.20:5080');

      await tester.tap(find.text('Varsayılana dön'));
      await tester.pumpAndSettle();

      expect(c.read(apiBaseUrlProvider), apiBase);
      expect(prefs.getString('api_base_override'), isNull);
      expect(find.text('Varsayılana dön'), findsNothing);
    });

    testWidgets('küçük ekranda (iPhone SE) taşma yok', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await openSettings(tester);
      expect(tester.takeException(), isNull);
    });
  });

  test('API adresi doğrulama', () {
    expect(
      normalizeApiBaseUrl('http://10.0.0.5:5080/'),
      'http://10.0.0.5:5080',
    );
    expect(normalizeApiBaseUrl('https://ornek.dev'), 'https://ornek.dev');
    expect(normalizeApiBaseUrl('localhost:5080'), isNull);
    expect(normalizeApiBaseUrl('ftp://x'), isNull);
    expect(normalizeApiBaseUrl(''), isNull);
  });
}
