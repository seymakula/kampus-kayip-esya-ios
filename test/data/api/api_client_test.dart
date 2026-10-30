import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/config.dart';
import 'package:kampus_kayip_esya/data/api/api_client.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/api/auth_interceptor.dart';

/// Ağa çıkmadan, isteği yakalayıp sabit yanıt döndüren adaptör.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, [this.body = '{}']);

  final int status;
  final String body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('varsayılan adres ve 10 sn zaman aşımı', () {
    final client = ApiClient();
    expect(client.dio.options.baseUrl, apiBase);
    expect(client.dio.options.connectTimeout, const Duration(seconds: 10));
    expect(client.dio.options.receiveTimeout, const Duration(seconds: 10));
  });

  test('token varsa Authorization başlığı eklenir', () async {
    FlutterSecureStorage.setMockInitialValues({TokenKeys.jwt: 'abc'});
    final adapter = _FakeAdapter(200, '{"ok":true}');
    final client = ApiClient(
      baseUrl: 'http://test',
      interceptors: [AuthInterceptor(const FlutterSecureStorage(), () {})],
    )..dio.httpClientAdapter = adapter;

    final res = await client.get('/api/auth/me', parse: (d) => d);
    expect(res, {'ok': true});
    expect(adapter.last!.headers['Authorization'], 'Bearer abc');
  });

  test('token yoksa başlık eklenmez', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final adapter = _FakeAdapter(200);
    final client = ApiClient(
      baseUrl: 'http://test',
      interceptors: [AuthInterceptor(const FlutterSecureStorage(), () {})],
    )..dio.httpClientAdapter = adapter;

    await client.get('/api/items', parse: (d) => d);
    expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
  });

  test('401 oturumu kapatır ve UnauthorizedException fırlatır', () async {
    FlutterSecureStorage.setMockInitialValues({TokenKeys.jwt: 'eski'});
    var signedOut = false;
    final client = ApiClient(
      baseUrl: 'http://test',
      interceptors: [
        AuthInterceptor(const FlutterSecureStorage(), () => signedOut = true),
      ],
    )..dio.httpClientAdapter = _FakeAdapter(401);

    await expectLater(
      client.get('/api/items/mine', parse: (d) => d),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(signedOut, isTrue);
  });
}
