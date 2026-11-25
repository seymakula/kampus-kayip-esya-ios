import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/app.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/create_item/device_services.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_auth_repository.dart';

class _FakePhotos implements PhotoSource {
  @override
  Future<String?> takePhoto() async =>
      throw StateError('simülatörde kamera yok');

  @override
  Future<List<String>> pickFromGallery(int limit) async =>
      ['/tmp/a.jpg', '/tmp/b.jpg'].take(limit).toList();
}

class _FakeLocation implements LocationService {
  _FakeLocation(this.result);
  LocationResult result;
  var settingsOpened = false;

  @override
  Future<LocationResult> current() async => result;

  @override
  Future<void> openSettings() async => settingsOpened = true;
}

class _RecordingRepo extends MockItemRepository {
  _RecordingRepo() : super(latency: Duration.zero);

  NewItem? created;
  final uploads = <List<String>>[];
  var failUploads = 0;

  @override
  Future<Item> createItem(NewItem item) {
    created = item;
    return super.createItem(item);
  }

  @override
  Future<Item> uploadPhotos(
    int itemId,
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  }) async {
    uploads.add(filePaths);
    if (failUploads-- > 0) {
      throw const NetworkException('Sunucuya bağlanılamadı.');
    }
    return super.uploadPhotos(itemId, filePaths, onProgress: onProgress);
  }
}

Future<void> _pumpCreate(
  WidgetTester tester, {
  required _RecordingRepo repo,
  required _FakeLocation location,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  FlutterSecureStorage.setMockInitialValues({
    'jwt': 'kayitli',
    'expiresAt': '2099-01-01T00:00:00.000Z',
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        itemRepositoryProvider.overrideWithValue(repo),
        photoSourceProvider.overrideWithValue(_FakePhotos()),
        locationServiceProvider.overrideWithValue(location),
      ],
      child: KampusKayipEsyaApp(onboardingPrefs: OnboardingPrefs(prefs)),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Yeni İlan'),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _tapButton(WidgetTester tester, String text) async {
  await tester.tap(find.widgetWithText(FilledButton, text));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  await tester.ensureVisible(_field(label));
  await tester.enterText(_field(label), text);
  await tester.pump();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _chooseCategory(WidgetTester tester, String name) async {
  final chip = find.widgetWithText(ChoiceChip, name);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pump();
}

/// Bulundu ilanını bilgiler adımının sonuna kadar doldurur.
Future<void> _fillFoundUntilLocation(WidgetTester tester) async {
  await _tapVisible(tester, find.text('Bir eşya buldum'));
  await _tapButton(tester, 'İleri');
  await _tapVisible(tester, find.widgetWithText(OutlinedButton, 'Galeri'));
  await _tapButton(tester, 'İleri');
  await _enter(tester, 'Başlık', 'Siyah deri cüzdan');
  await _chooseCategory(tester, 'Cüzdan');
  await _enter(tester, 'Açıklama', 'Amfinin arka sıralarında buldum.');
  await _enter(tester, 'Doğrulama sorusu', 'Kart hangi bankanın?');
  await _tapButton(tester, 'İleri');
}

void main() {
  testWidgets('baştan sona bulunan eşya ilanı açılır', (tester) async {
    final repo = _RecordingRepo();
    final location = _FakeLocation(const LocationFound(39.77855, 32.80395));
    await _pumpCreate(tester, repo: repo, location: location);

    expect(find.text('Adım 1/4 · Tür'), findsOneWidget);
    await _tapButton(tester, 'İleri');
    expect(find.text('İlan türünü seçin.'), findsOneWidget);

    await _tapVisible(tester, find.text('Bir eşya buldum'));
    await _tapButton(tester, 'İleri');
    expect(find.text('Adım 2/4 · Fotoğraf'), findsOneWidget);

    // Simülatörde kamera yok: anlamlı mesaj, akış tıkanmaz.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Kamera'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kamera kullanılamıyor'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Galeri'));
    await tester.pumpAndSettle();
    expect(find.text('2/5 fotoğraf'), findsOneWidget);
    expect(find.text('KAPAK'), findsOneWidget);
    await _tapButton(tester, 'İleri');

    // Boş bilgilerle ileri: alan hataları görünür, adım geçilmez.
    await _tapButton(tester, 'İleri');
    expect(find.text('Adım 3/4 · Bilgiler'), findsOneWidget);
    expect(find.text('Başlık zorunludur.'), findsWidgets);

    await _enter(tester, 'Başlık', 'Siyah deri cüzdan');
    await _chooseCategory(tester, 'Cüzdan');
    await _enter(tester, 'Açıklama', 'Amfinin arka sıralarında buldum.');
    await _enter(tester, 'Doğrulama sorusu', 'Kart hangi bankanın?');
    await _tapButton(tester, 'İleri');
    expect(find.text('Adım 4/4 · Konum'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Şu anki konumum'));
    await tester.pumpAndSettle();
    expect(find.text('Merkez Yemekhane'), findsWidgets);
    expect(find.textContaining('En yakın bina seçildi'), findsOneWidget);
    // Önizleme kartı.
    expect(find.text('Siyah deri cüzdan'), findsOneWidget);

    await _tapButton(tester, 'Yayınla');

    final sent = repo.created!;
    expect(sent.type, ItemType.found);
    expect(sent.title, 'Siyah deri cüzdan');
    expect(sent.categoryId, 2);
    expect(sent.verificationQuestion, 'Kart hangi bankanın?');
    expect(sent.locationId, 3);
    expect(repo.uploads.single, ['/tmp/a.jpg', '/tmp/b.jpg']);
    expect(
      find.text('İlanın görevli onayından sonra yayınlanacak.'),
      findsOneWidget,
    );
    expect(find.text('Kampüs Kayıp Eşya'), findsOneWidget); // ana sayfa

    // Taslak sıfırlandı: form baştan.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Yeni İlan'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adım 1/4 · Tür'), findsOneWidget);
  });

  testWidgets('kayıp ilanında doğrulama sorusu alanı yok', (tester) async {
    await _pumpCreate(
      tester,
      repo: _RecordingRepo(),
      location: _FakeLocation(const LocationDenied()),
    );
    await tester.tap(find.text('Bir şeyimi kaybettim'));
    await tester.pump();
    await _tapButton(tester, 'İleri');
    await _tapButton(tester, 'İleri');

    expect(find.text('Adım 3/4 · Bilgiler'), findsOneWidget);
    expect(_field('Doğrulama sorusu'), findsNothing);
    expect(find.text('Kaybolma tarihi'), findsOneWidget);
  });

  testWidgets('geri dönünce girilen bilgiler kaybolmaz', (tester) async {
    await _pumpCreate(
      tester,
      repo: _RecordingRepo(),
      location: _FakeLocation(const LocationDenied()),
    );
    await tester.tap(find.text('Bir şeyimi kaybettim'));
    await tester.pump();
    await _tapButton(tester, 'İleri');
    await _tapButton(tester, 'İleri');
    await _enter(tester, 'Başlık', 'Gümüş bilezik');

    await tester.tap(find.widgetWithText(OutlinedButton, 'Geri'));
    await tester.pumpAndSettle();
    await _tapButton(tester, 'İleri');

    expect(find.text('Gümüş bilezik'), findsOneWidget);
  });

  testWidgets('konum izni reddedilirse listeden seçilir', (tester) async {
    final location = _FakeLocation(const LocationDenied());
    await _pumpCreate(tester, repo: _RecordingRepo(), location: location);
    await _fillFoundUntilLocation(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Şu anki konumum'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Konum izni verilmedi'), findsOneWidget);

    await tester.tap(find.text('Bina seç'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'kütüp');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Merkez Kütüphane'));
    await tester.pumpAndSettle();
    expect(find.text('Merkez Kütüphane'), findsWidgets);
  });

  testWidgets('kalıcı retde Ayarları aç önerilir', (tester) async {
    final location = _FakeLocation(const LocationDeniedForever());
    await _pumpCreate(tester, repo: _RecordingRepo(), location: location);
    await _fillFoundUntilLocation(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Şu anki konumum'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Ayarları aç'));
    expect(location.settingsOpened, isTrue);
  });

  testWidgets('fotoğraf yüklenemezse tekrar denenir, ilan açık kalır', (
    tester,
  ) async {
    final repo = _RecordingRepo()..failUploads = 1;
    await _pumpCreate(
      tester,
      repo: repo,
      location: _FakeLocation(const LocationFound(39.77855, 32.80395)),
    );
    await _fillFoundUntilLocation(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Şu anki konumum'));
    await tester.pumpAndSettle();

    // Yayınlarken düğmede dönen gösterge var; pumpAndSettle beklemez.
    await tester.tap(find.widgetWithText(FilledButton, 'Yayınla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Fotoğraflar yüklenemedi'), findsOneWidget);
    expect(repo.created, isNotNull);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(repo.uploads, hasLength(2));
    expect(
      find.text('İlanın görevli onayından sonra yayınlanacak.'),
      findsOneWidget,
    );
  });

  testWidgets('küçük ekranda (iPhone SE) adımlar taşmaz', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pumpCreate(
      tester,
      repo: _RecordingRepo(),
      location: _FakeLocation(const LocationFound(39.77855, 32.80395)),
    );
    await _fillFoundUntilLocation(tester);
    expect(tester.takeException(), isNull);
  });
}
