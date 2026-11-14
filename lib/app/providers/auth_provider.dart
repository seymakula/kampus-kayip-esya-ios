import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/app_exception.dart';
import '../../data/api/auth_interceptor.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import 'core_providers.dart';

enum AuthStatus {
  /// Açılışta kayıtlı oturum henüz kontrol ediliyor.
  unknown,
  signedOut,
  signedIn,
}

/// Oturum durumu. Router buna bakarak yönlendirir.
class AuthState {
  const AuthState.unknown() : status = AuthStatus.unknown, user = null;

  const AuthState.signedOut() : status = AuthStatus.signedOut, user = null;

  const AuthState.signedIn(User this.user) : status = AuthStatus.signedIn;

  final AuthStatus status;
  final User? user;

  bool get isLoggedIn => status == AuthStatus.signedIn;
}

/// Token Keychain'de (`jwt`, `expiresAt`) durur; açılışta süresi geçmemişse
/// `GET /api/auth/me` ile doğrulanır ve giriş ekranı görünmeden oturum açılır.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restore);
    return const AuthState.unknown();
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await _start(session);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String studentNo,
    required String password,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .register(
          fullName: fullName,
          email: email,
          studentNo: studentNo,
          password: password,
        );
    await _start(session);
  }

  /// Profil bilgisini sunucudan yeniler (Profil'de aşağı çekince).
  Future<void> refreshUser() async {
    if (!state.isLoggedIn) return;
    final user = await ref.read(authRepositoryProvider).me();
    if (ref.mounted && state.isLoggedIn) state = AuthState.signedIn(user);
  }

  /// Token Keychain'den silinir; oturuma bağlı veriler (ilan listeleri)
  /// kullanıcı değiştiği için kendiliğinden yeniden yüklenir.
  Future<void> signOut() async {
    if (!state.isLoggedIn) return;
    await _clearToken();
    state = const AuthState.signedOut();
  }

  Future<void> _start(AuthSession session) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: TokenKeys.jwt, value: session.token);
    await storage.write(
      key: TokenKeys.expiresAt,
      value: session.expiresAt.toUtc().toIso8601String(),
    );
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = AuthState.signedIn(user);
    } catch (_) {
      // Kullanıcı alınamadıysa yarım oturum bırakma.
      await _clearToken();
      rethrow;
    }
  }

  Future<void> _restore() async {
    AuthState next = const AuthState.signedOut();
    try {
      if (await _hasValidToken()) {
        next = AuthState.signedIn(await ref.read(authRepositoryProvider).me());
      } else {
        await _clearToken();
      }
    } on UnauthorizedException {
      await _clearToken();
    } catch (_) {
      // Ağ hatası vb.: token silinmez, sonraki açılışta yeniden denenir.
    } finally {
      // Ne olursa olsun yükleniyor ekranında takılı kalınmaz.
      if (ref.mounted) state = next;
    }
  }

  Future<bool> _hasValidToken() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: TokenKeys.jwt);
    final expiresAt = DateTime.tryParse(
      await storage.read(key: TokenKeys.expiresAt) ?? '',
    );
    return token != null &&
        expiresAt != null &&
        expiresAt.isAfter(DateTime.now());
  }

  Future<void> _clearToken() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: TokenKeys.jwt);
    await storage.delete(key: TokenKeys.expiresAt);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
