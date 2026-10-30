import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain anahtarları. Hafta 3'te giriş yapılınca buraya yazılır.
abstract final class TokenKeys {
  static const jwt = 'jwt';
  static const expiresAt = 'expiresAt';
}

/// Her isteğe `Authorization: Bearer <jwt>` ekler; 401 gelirse oturumu kapatır.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._onUnauthorized);

  final FlutterSecureStorage _storage;
  final void Function() _onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: TokenKeys.jwt);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) _onUnauthorized();
    handler.next(err);
  }
}
