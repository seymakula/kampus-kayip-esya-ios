# Kampüs Kayıp Eşya – iOS

BLM4587 Mobil Uygulama Geliştirme (iOS) dönem projesi · 2026–2027 Güz

Öğrencinin kampüste kaybettiği ya da bulduğu bir eşyayı iPhone'undan, fotoğrafını
çekip konumunu işaretleyerek birkaç saniyede ilan olarak paylaşmasını sağlayan
Flutter uygulaması. BLM4581 projesindeki ortak ASP.NET Core Web API'ye bağlanır;
ilan onayı ve yönetim işlemleri web panelindedir.

## Ekip

| Ad Soyad     | Öğrenci No | Liderlik      |
| ------------ | ---------- | ------------- |
| Barış Coşkun | 23291721   | 1–4. haftalar |
| Şeyma Kula   | 23291513   | 5–9. haftalar |

## Gereksinimler

- Flutter (stable) / Dart `^3.13`
- iOS 16 veya üzeri (iPhone)
- macOS'ta Xcode: imzalama, simülatör ve gerçek cihaz için

## Çalıştırma

```bash
flutter pub get
flutter run                 # bağlı cihaz veya açık simülatör
flutter test                # birim ve widget testleri
flutter analyze
```

Model dosyaları (`*.freezed.dart`, `*.g.dart`) depoya eklenmiştir. Bir modeli
değiştirdikten sonra yeniden üretmek için:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Splash ekranı `pubspec.yaml` içindeki `flutter_native_splash` ayarından üretilir:
`dart run flutter_native_splash:create`

## Klasör yapısı

```
lib/
├── main.dart                 # giriş noktası
├── app/
│   ├── app.dart              # MaterialApp.router, tema
│   ├── config.dart           # API_BASE adresi, zaman aşımı
│   ├── providers/            # Riverpod: storage, ApiClient, repository, oturum
│   ├── router/
│   │   ├── app_routes.dart   # tüm rota yolları (sabitler)
│   │   └── app_router.dart   # go_router yapılandırması, yönlendirmeler
│   ├── shell/main_shell.dart # 5 sekmeli alt menü
│   └── theme/                # renkler, açık/koyu tema
├── data/
│   ├── models/               # freezed modeller (User, Item, Claim, ...)
│   ├── api/                  # ApiClient (dio), AuthInterceptor, AppException
│   ├── mock/                 # API hazır olana kadar örnek veri
│   └── repositories/         # veri erişim arayüzleri ve uygulamaları
├── features/                 # her ekran kendi klasöründe
│   ├── onboarding/  auth/  home/  search/  create_item/
│   └── messages/  profile/  item_detail/  notifications/
└── shared/widgets/           # birden çok ekranda kullanılan bileşenler
test/                         # lib/ ile aynı düzende testler
```

## API adresi

Uygulama BLM4581 projesindeki ortak Web API'ye bağlanır. Adres derleme anında
verilir (varsayılan `http://localhost:5080`):

```bash
# Simülatör (API aynı Mac'te)
flutter run --dart-define=API_BASE=http://localhost:5080
# Gerçek iPhone (Mac'in yerel IP'si: ipconfig getifaddr en0)
flutter run --dart-define=API_BASE=http://192.168.1.20:5080
```

Telefon ve bilgisayar aynı ağda olmalı; web tarafında Kestrel `http://0.0.0.0:5080`
dinlemeli.

## Durum yönetimi (Riverpod)

Kökte `ProviderScope` vardır. Temel provider'lar `lib/app/providers/` altında:

| Provider                 | Ne döner                                                  |
| ------------------------ | --------------------------------------------------------- |
| `secureStorageProvider`  | `FlutterSecureStorage` (iOS'ta Keychain)                  |
| `apiClientProvider`      | Tek `Dio` örneği + `AuthInterceptor` (token ekler, 401'de çıkış) |
| `itemRepositoryProvider` | Şimdilik `MockItemRepository`; API'ye geçiş tek satır     |
| `authStateProvider`      | Oturum durumu (`AuthState.isLoggedIn`, `user`)            |

Veri ekranları `AsyncNotifier` + ortak `AsyncValueView` kalıbını kullanır
(örnek: `features/home/item_list_provider.dart`). Repository'ler `DioException`
yerine `AppException` (`NetworkException`, `ServerException`,
`ValidationException`, `UnauthorizedException`) fırlatır; mesajlar Türkçedir.

## Gezinme

| Yol              | Ekran                                   |
| ---------------- | --------------------------------------- |
| `/onboarding`    | İlk açılış tanıtımı                     |
| `/login`         | Giriş                                   |
| `/register`      | Kayıt                                   |
| `/`              | **Ana Sayfa** sekmesi (Kayıp / Bulunan) |
| `/search`        | **Ara** sekmesi                         |
| `/create`        | **Yeni İlan** sekmesi                   |
| `/messages`      | **Mesajlar** sekmesi                    |
| `/profile`       | **Profil** sekmesi                      |
| `/items/:id`     | İlan detayı (alt menünün üstünde)       |
| `/notifications` | Bildirimler (alt menünün üstünde)       |

Sekmeler `StatefulShellRoute.indexedStack` ile kurulur; her sekme kendi
gezinme geçmişini korur. Yollar elle yazılmaz, `AppRoutes` sabitleri kullanılır:

```dart
context.push(AppRoutes.itemDetail(item.id));
```

## Çalışma düzeni

- Her iş için ayrı dal: `hNN/kisa-aciklama` (ör. `h02/giris-kayit`).
- Commit mesajı: `Hafta N (Ad): yapılan iş`.
- İki üye de kendi GitHub hesabıyla en az haftada bir push yapar.
- Push öncesi `flutter analyze` ve `flutter test` temiz olmalı.

## Haftalık plan (özet)

| Hafta | Lider | Barış                                        | Şeyma                                        |
| ----- | ----- | -------------------------------------------- | -------------------------------------------- |
| 1     | Barış | Proje yapısı, README, tema, router, alt menü | Modeller, mock veri, açılış ve tanıtım       |
| 2     | Barış | Giriş/kayıt ekranları, ana sayfa kartları    | dio API istemcisi, Riverpod kurulumu         |
| 3     | Barış | Liste API'den, yenileme, sonsuz kaydırma, ara | Giriş API'si, Keychain, otomatik giriş       |
| 4     | Barış | İlan detayı, fotoğraf galerisi               | Profil, ayarlar, çıkış                       |
| 5     | Şeyma | Fotoğraf sıkıştırma ve yükleme               | İlan aç formu, kamera/galeri, konum          |
| 6     | Şeyma | İlanlarım, talepler, onayla/reddet           | "Bu benim" talebi, eşleşmeler                |
| 7     | Şeyma | Bildirimler, rozet, yerel bildirim           | SignalR sohbet                               |
| 8     | Şeyma | Harita, izin reddi akışları                  | Karanlık mod, yükleniyor/boş/hata durumları  |
| 9     | Şeyma | Widget testleri, hata düzeltme               | Gerçek cihaz testi, demo videosu             |
