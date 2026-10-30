import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/auth_interceptor.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import 'core_providers.dart';

/// Oturum durumu. `user == null` → giriş yapılmamış.
class AuthState {
  const AuthState({this.user});

  const AuthState.signedOut() : user = null;

  final User? user;

  bool get isLoggedIn => user != null;
}

/// Hafta 2: her zaman mock kullanıcıyla "giriş yapmış" başlar.
/// Hafta 3: `build` Keychain'deki token'a bakıp `GET /api/auth/me` çağıracak;
/// `login` / `register` buraya eklenecek.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(user: mockCurrentUser);

  Future<void> signOut() async {
    if (!state.isLoggedIn) return;
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: TokenKeys.jwt);
    await storage.delete(key: TokenKeys.expiresAt);
    state = const AuthState.signedOut();
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
