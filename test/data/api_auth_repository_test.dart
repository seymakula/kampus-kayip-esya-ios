import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/api/api_client.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/repositories/api_auth_repository.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int status;
  final Object? body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(ApiAuthRepository, _FakeAdapter) _repo(int status, Object? body) {
  final adapter = _FakeAdapter(status, body);
  final client = ApiClient(baseUrl: 'http://test')
    ..dio.httpClientAdapter = adapter;
  return (ApiAuthRepository(client), adapter);
}

const _session = {'token': 'abc', 'expiresAt': '2030-01-02T03:04:05Z'};

void main() {
  test('giriş doğru uca gider, token ve süre okunur', () async {
    final (repo, adapter) = _repo(200, _session);

    final session = await repo.login(email: 'a@ankara.edu.tr', password: 'x');

    expect(adapter.last!.path, '/api/auth/login');
    expect(adapter.last!.method, 'POST');
    expect(adapter.last!.data, {'email': 'a@ankara.edu.tr', 'password': 'x'});
    expect(session.token, 'abc');
    expect(session.expiresAt, DateTime.utc(2030, 1, 2, 3, 4, 5));
  });

  test('girişte 401 "şifre hatalı" mesajı olur', () async {
    final (repo, _) = _repo(401, null);

    await expectLater(
      repo.login(email: 'a@ankara.edu.tr', password: 'x'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'E-posta veya şifre hatalı.',
        ),
      ),
    );
  });

  test('kayıt web\'in beklediği alanları gönderir', () async {
    final (repo, adapter) = _repo(200, _session);

    await repo.register(
      fullName: 'Şeyma Kula',
      email: 's@ogrenci.ankara.edu.tr',
      studentNo: '23291513',
      password: 'Sifre123!',
    );

    expect(adapter.last!.path, '/api/auth/register');
    expect(adapter.last!.data, {
      'fullName': 'Şeyma Kula',
      'email': 's@ogrenci.ankara.edu.tr',
      'studentNo': '23291513',
      'password': 'Sifre123!',
      'confirmPassword': 'Sifre123!',
    });
  });

  test('kayıtta sunucu doğrulama hatası ValidationException olur', () async {
    final (repo, _) = _repo(400, {
      'title': 'Hata',
      'errors': {
        'Email': ['Bu e-posta zaten kayıtlı.'],
      },
    });

    await expectLater(
      repo.register(
        fullName: 'A B',
        email: 'a@ankara.edu.tr',
        studentNo: '23291513',
        password: 'Sifre123!',
      ),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.errorFor('email'),
          'email',
          'Bu e-posta zaten kayıtlı.',
        ),
      ),
    );
  });

  test('me: Identity kimliği metin, öğrenci no boş olabilir', () async {
    final (repo, adapter) = _repo(200, {
      'id': '6f1c7b52-aaaa-bbbb-cccc-1234567890ab',
      'fullName': 'Test Görevlisi',
      'email': 'gorevli@ankara.edu.tr',
      'studentNo': null,
    });

    final user = await repo.me();

    expect(adapter.last!.path, '/api/auth/me');
    expect(user.id, '6f1c7b52-aaaa-bbbb-cccc-1234567890ab');
    expect(user.studentNo, isNull);
  });

  test('beklenmeyen yanıt çökme yerine anlamlı hata verir', () async {
    final (eksikToken, _) = _repo(200, {'expiresAt': '2030-01-01T00:00:00Z'});
    await expectLater(
      eksikToken.login(email: 'a@ankara.edu.tr', password: 'x'),
      throwsA(isA<ServerException>()),
    );

    final (bozukUser, _) = _repo(200, {'id': 5});
    await expectLater(bozukUser.me(), throwsA(isA<ServerException>()));
  });
}
