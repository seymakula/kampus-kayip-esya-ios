import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/api/api_client.dart';
import '../../data/api/auth_interceptor.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/mock_item_repository.dart';
import 'auth_provider.dart';

/// iOS'ta Keychain, Android'de EncryptedSharedPreferences.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  ),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
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

/// API hazır olunca (Hafta 3) yalnızca bu satır değişir:
/// `ApiItemRepository(ref.watch(apiClientProvider))`.
final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) => MockItemRepository(),
);
