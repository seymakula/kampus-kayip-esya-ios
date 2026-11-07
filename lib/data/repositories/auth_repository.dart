import '../models/models.dart';

/// Giriş veya kayıt sonrası sunucunun verdiği oturum: `{ token, expiresAt }`.
class AuthSession {
  const AuthSession({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}

/// Ekranlar ve `authStateProvider` yalnızca bu arayüzü bilir.
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String studentNo,
    required String password,
  });

  /// Oturumu açık kullanıcı. Token'ı `AuthInterceptor` ekler.
  Future<User> me();
}
