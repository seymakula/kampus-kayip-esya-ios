import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/app/router/app_router.dart';
import 'package:kampus_kayip_esya/app/router/app_routes.dart';
import 'package:kampus_kayip_esya/app/theme/app_theme.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/mock_item_repository.dart';
import 'package:kampus_kayip_esya/features/item_detail/item_detail_screen.dart';
import 'package:kampus_kayip_esya/features/item_detail/photo_gallery_screen.dart';
import 'package:kampus_kayip_esya/features/onboarding/onboarding_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3 fotoğraflı bir ilan (id 999) ekleyen, istenirse hata veren repository.
class _DetailRepository extends MockItemRepository {
  _DetailRepository() : super(latency: Duration.zero);

  static final multiPhoto = mockItems.first.copyWith(
    id: 999,
    title: 'Üç fotoğraflı cüzdan',
    photos: const [
      ItemPhoto(id: 901, url: 'assets/mock/cuzdan_kahve.jpg'),
      ItemPhoto(id: 902, url: 'assets/mock/canta_gri.jpg', sortOrder: 1),
      ItemPhoto(id: 903, url: 'assets/mock/anahtar_kirmizi.jpg', sortOrder: 2),
    ],
  );

  bool fail = false;

  @override
  Future<Item> getItem(int id) async {
    if (fail) throw const NetworkException('Sunucuya bağlanılamadı.');
    return id == multiPhoto.id ? multiPhoto : super.getItem(id);
  }
}

Item _mock(int id) => mockItems.firstWhere((i) => i.id == id);

Future<_DetailRepository> _pumpDetail(
  WidgetTester tester,
  int id, {
  bool fail = false,
}) async {
  _usePhoneSize(tester);
  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
  final router = createAppRouter(
    onboardingPrefs: prefs,
    initialLocation: AppRoutes.itemDetail(id),
  );
  addTearDown(router.dispose);
  final repo = _DetailRepository()..fail = fail;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(repo)],
      retry: (_, _) => null,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// iPhone 14 (390×844 pt). Varsayılan 800×600 yatay test ekranında 4:3
/// fotoğraf neredeyse tüm yüksekliği kaplar.
void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Finder _inDetail(Finder f) =>
    find.descendant(of: find.byType(ItemDetailScreen), matching: f);

void main() {
  testWidgets('bulunan ilan: başlık, bilgiler, açıklama ve "Bu benim"', (
    tester,
  ) async {
    final item = _mock(1); // bulunan cüzdan
    await _pumpDetail(tester, item.id);

    expect(_inDetail(find.text(item.title)), findsOneWidget);
    expect(_inDetail(find.text('Bulundu')), findsOneWidget);
    expect(_inDetail(find.text(item.category.name)), findsOneWidget);
    expect(_inDetail(find.text(item.location.name)), findsOneWidget);
    expect(_inDetail(find.text('Bulunduğu yer')), findsOneWidget);
    expect(_inDetail(find.text(item.description)), findsOneWidget);
    expect(_inDetail(find.textContaining('doğrulama')), findsOneWidget);
    // Doğrulama sorusunun kendisi ilanda gösterilmez.
    expect(find.text(item.verificationQuestion!), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Bu benim'), findsOneWidget);
  });

  testWidgets('kayıp ilanında "Ben buldum", doğrulama notu yok', (
    tester,
  ) async {
    final item = _mock(2); // kayıp anahtar
    await _pumpDetail(tester, item.id);

    expect(_inDetail(find.text('Kaybolduğu yer')), findsOneWidget);
    expect(_inDetail(find.textContaining('doğrulama')), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Ben buldum'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Ben buldum'));
    await tester.pump();
    expect(find.textContaining('yakında'), findsOneWidget);
  });

  testWidgets('teslim edilmiş ilanda durum yazar, talep düğmesi yok', (
    tester,
  ) async {
    await _pumpDetail(tester, 20); // teslim edildi, fotoğrafsız

    expect(_inDetail(find.text('Teslim edildi')), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(_inDetail(find.byIcon(Icons.image_outlined)), findsOneWidget);
  });

  testWidgets('yüklenemezse hata ve Tekrar dene', (tester) async {
    final repo = await _pumpDetail(tester, 1, fail: true);

    expect(find.text('Sunucuya bağlanılamadı.'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(_inDetail(find.text(_mock(1).title)), findsOneWidget);
  });

  testWidgets('fotoğraflar kaydırılır, sayaç güncellenir', (tester) async {
    await _pumpDetail(tester, 999);

    expect(find.text('1 / 3'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('fotoğrafa dokununca galeri o fotoğrafta açılır, kapatılır', (
    tester,
  ) async {
    await _pumpDetail(tester, 999);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoGalleryScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('2 / 3')),
      findsOneWidget,
    );

    final gallery = find.descendant(
      of: find.byType(PhotoGalleryScreen),
      matching: find.byType(PageView),
    );
    await tester.drag(gallery, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoGalleryScreen), findsNothing);
    expect(_inDetail(find.text('Üç fotoğraflı cüzdan')), findsOneWidget);
  });

  testWidgets('çift dokunuş yakınlaştırır, yakınken sayfa kaymaz', (
    tester,
  ) async {
    await _pumpDetail(tester, 999);
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();

    final gallery = find.descendant(
      of: find.byType(PhotoGalleryScreen),
      matching: find.byType(PageView),
    );
    double scale() => tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer).first)
        .transformationController!
        .value
        .getMaxScaleOnAxis();

    Future<void> doubleTap() async {
      final center = tester.getCenter(gallery);
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(center);
      await tester.pumpAndSettle();
    }

    await doubleTap();
    expect(scale(), greaterThan(1));
    expect(
      tester.widget<PageView>(gallery).physics,
      isA<NeverScrollableScrollPhysics>(),
    );

    await doubleTap();
    expect(scale(), 1);
    await tester.drag(gallery, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('galeri yolu doğrudan açılabilir, sıra sınırlanır', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final prefs = OnboardingPrefs(await SharedPreferences.getInstance());
    final router = createAppRouter(
      onboardingPrefs: prefs,
      initialLocation: AppRoutes.itemPhotos(999, index: 9),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider.overrideWithValue(_DetailRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 / 3'), findsOneWidget);
  });

  testWidgets('küçük ekranda (iPhone SE) taşma yok', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _pumpDetail(tester, 1);
    expect(tester.takeException(), isNull);
  });
}
