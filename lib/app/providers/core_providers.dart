import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/api_client.dart';
import '../../data/api/auth_interceptor.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../data/repositories/api_item_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_item_repository.dart';
import '../config.dart';
import 'auth_provider.dart';

/// iOS'ta Keychain, Android'de EncryptedSharedPreferences.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  ),
);

/// `main()` gerçek örnekle değiştirir. Verilmezse (ör. testlerde) kayıtlı
/// ayar okunmaz, varsayılanlar kullanılır.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Kullanılan API adresi. Varsayılan `--dart-define=API_BASE`; yalnızca debug
/// derlemede Ayarlar'dan değiştirilebilir (gösterimde IP değişirse diye).
class ApiBaseUrlNotifier extends Notifier<String> {
  static const _key = 'api_base_override';

  @override
  String build() {
    if (!kDebugMode) return apiBase;
    return ref.watch(sharedPreferencesProvider)?.getString(_key) ?? apiBase;
  }

  bool get isOverridden => state != apiBase;

  Future<void> set(String url) async {
    await ref.read(sharedPreferencesProvider)?.setString(_key, url);
    state = url;
  }

  Future<void> reset() async {
    await ref.read(sharedPreferencesProvider)?.remove(_key);
    state = apiBase;
  }
}

final apiBaseUrlProvider = NotifierProvider<ApiBaseUrlNotifier, String>(
  ApiBaseUrlNotifier.new,
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    interceptors: [
      AuthInterceptor(
        ref.watch(secureStorageProvider),
        // 401 → token silinir, oturum kapanır (Hafta 3'te router girişe yönlendirir).
        () => ref.read(authStateProvider.notifier).signOut(),
      ),
    ],
  );
  ref.onDispose(client.dio.close);
  return client;
});

/// Varsayılan: ortak Web API. `--dart-define=USE_MOCK=true` ile örnek veri.
final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => useMockData
      ? MockItemRepository()
      : ApiItemRepository(ref.watch(apiClientProvider)),
);

/// Varsayılan: ortak Web API. `--dart-define=USE_MOCK=true` ile örnek veri.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => useMockData
      ? MockAuthRepository()
      : ApiAuthRepository(ref.watch(apiClientProvider)),
);
