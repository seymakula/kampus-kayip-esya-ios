import '../api/api_client.dart';
import '../api/app_exception.dart';
import '../models/models.dart';
import 'auth_repository.dart';

/// Ortak Web API (BLM4581) üzerinden giriş ve kayıt.
///
/// | İstek                     | Gövde                                                      | Yanıt                  |
/// | ------------------------- | ---------------------------------------------------------- | ---------------------- |
/// | `POST /api/auth/login`    | `email, password`                                          | `{ token, expiresAt }` |
/// | `POST /api/auth/register` | `fullName, email, studentNo, password, confirmPassword`    | `{ token, expiresAt }` |
/// | `GET /api/auth/me`        | —                                                          | `User`                 |
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.post(
        '/api/auth/login',
        body: {'email': email, 'password': password},
        parse: _parseSession,
      );
    } on UnauthorizedException {
      // Girişte 401 "oturum düştü" değil, yanlış bilgi demektir.
      throw const ServerException(401, 'E-posta veya şifre hatalı.');
    }
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String studentNo,
    required String password,
  }) => _client.post(
    '/api/auth/register',
    body: {
      'fullName': fullName,
      'email': email,
      'studentNo': studentNo,
      'password': password,
      // Şifre tekrarı formda doğrulandı; web kaydı bu alanı da bekliyor.
      'confirmPassword': password,
    },
    parse: _parseSession,
  );

  @override
  Future<User> me() => _client.get(
    '/api/auth/me',
    parse: (data) {
      if (data is! Map<String, dynamic>) throw _unexpectedResponse;
      try {
        return User.fromJson(data);
      } on TypeError {
        throw _unexpectedResponse;
      }
    },
  );

  AuthSession _parseSession(Object? data) {
    if (data is Map) {
      final token = data['token'];
      final expiresAt = data['expiresAt'];
      final expiry = expiresAt is String ? DateTime.tryParse(expiresAt) : null;
      if (token is String && token.isNotEmpty && expiry != null) {
        return AuthSession(token: token, expiresAt: expiry);
      }
    }
    throw _unexpectedResponse;
  }

  static const _unexpectedResponse = ServerException(
    200,
    'Sunucudan beklenmeyen bir yanıt alındı.',
  );
}
