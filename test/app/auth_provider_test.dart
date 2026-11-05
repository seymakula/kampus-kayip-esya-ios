import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/app/providers/auth_provider.dart';
import 'package:kampus_kayip_esya/app/providers/core_providers.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';

import '../helpers/fake_auth_repository.dart';

const _valid = {'jwt': 'kayitli', 'expiresAt': '2099-01-01T00:00:00.000Z'};

ProviderContainer _container(FakeAuthRepository repo) {
  final c = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

/// Açılıştaki oturum kontrolünün bitmesini bekler.
Future<AuthState> _restored(ProviderContainer c) {
  final done = Completer<AuthState>();
  c.listen(authStateProvider, (_, next) {
    if (next.status != AuthStatus.unknown && !done.isCompleted) {
      done.complete(next);
    }
  }, fireImmediately: true);
  return done.future;
}

Future<String?> _jwt(ProviderContainer c) =>
    c.read(secureStorageProvider).read(key: 'jwt');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('açılışta otomatik giriş', () {
    test('geçerli token + me başarılı: giriş yapılmış açılır', () async {
      FlutterSecureStorage.setMockInitialValues(Map.of(_valid));
      final repo = FakeAuthRepository();
      final c = _container(repo);

      final state = await _restored(c);

      expect(state.isLoggedIn, isTrue);
      expect(state.user, isNotNull);
      expect(repo.meCalls, 1);
    });

    test('token yok: sunucuya gitmeden çıkış durumu', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final repo = FakeAuthRepository();
      final c = _container(repo);

      expect((await _restored(c)).status, AuthStatus.signedOut);
      expect(repo.meCalls, 0);
    });

    test('süresi geçmiş token: sunucuya gitmeden silinir', () async {
      FlutterSecureStorage.setMockInitialValues({
        'jwt': 'eski',
        'expiresAt': '2020-01-01T00:00:00.000Z',
      });
      final repo = FakeAuthRepository();
      final c = _container(repo);

      expect((await _restored(c)).status, AuthStatus.signedOut);
      expect(repo.meCalls, 0);
      expect(await _jwt(c), isNull);
    });

    test('bozuk süre bilgisi geçersiz sayılır', () async {
      FlutterSecureStorage.setMockInitialValues({
        'jwt': 'x',
        'expiresAt': 'bozuk',
      });
      final c = _container(FakeAuthRepository());

      expect((await _restored(c)).status, AuthStatus.signedOut);
      expect(await _jwt(c), isNull);
    });

    test('me 401: token silinir', () async {
      FlutterSecureStorage.setMockInitialValues(Map.of(_valid));
      final repo = FakeAuthRepository()
        ..meError = const UnauthorizedException();
      final c = _container(repo);

      expect((await _restored(c)).status, AuthStatus.signedOut);
      expect(await _jwt(c), isNull);
    });

    test('ağ hatası: girişe düşer ama token silinmez', () async {
      FlutterSecureStorage.setMockInitialValues(Map.of(_valid));
      final repo = FakeAuthRepository()
        ..meError = const NetworkException('Bağlantı yok');
      final c = _container(repo);

      expect((await _restored(c)).status, AuthStatus.signedOut);
      expect(await _jwt(c), 'kayitli');
    });

    test('beklenmeyen hatada yükleniyorda takılı kalmaz', () async {
      FlutterSecureStorage.setMockInitialValues(Map.of(_valid));
      final repo = FakeAuthRepository()..meError = StateError('beklenmedik');
      final c = _container(repo);

      expect((await _restored(c)).status, AuthStatus.signedOut);
    });
  });

  group('giriş ve çıkış', () {
    test('giriş token ve süreyi Keychain anahtarlarına yazar', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final c = _container(FakeAuthRepository());
      await _restored(c);

      await c
          .read(authStateProvider.notifier)
          .login(email: 'a@ankara.edu.tr', password: 'x');

      expect(c.read(authStateProvider).isLoggedIn, isTrue);
      expect(await _jwt(c), 'yeni-token');
      expect(
        await c.read(secureStorageProvider).read(key: 'expiresAt'),
        '2099-01-01T00:00:00.000Z',
      );
    });

    test('girişten sonra me başarısızsa token kalmaz', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final repo = FakeAuthRepository();
      final c = _container(repo);
      await _restored(c);
      repo.meError = const NetworkException('Bağlantı yok');

      await expectLater(
        c
            .read(authStateProvider.notifier)
            .login(email: 'a@ankara.edu.tr', password: 'x'),
        throwsA(isA<NetworkException>()),
      );

      expect(c.read(authStateProvider).isLoggedIn, isFalse);
      expect(await _jwt(c), isNull);
    });

    test('hatalı giriş oturumu değiştirmez', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final repo = FakeAuthRepository()
        ..loginError = const ServerException(401, 'E-posta veya şifre hatalı.');
      final c = _container(repo);
      await _restored(c);

      await expectLater(
        c
            .read(authStateProvider.notifier)
            .login(email: 'a@ankara.edu.tr', password: 'x'),
        throwsA(isA<ServerException>()),
      );
      expect(c.read(authStateProvider).status, AuthStatus.signedOut);
    });

    test('signOut token\'ı siler ve oturumu kapatır', () async {
      FlutterSecureStorage.setMockInitialValues(Map.of(_valid));
      final c = _container(FakeAuthRepository());
      await _restored(c);

      await c.read(authStateProvider.notifier).signOut();

      expect(c.read(authStateProvider).status, AuthStatus.signedOut);
      expect(await _jwt(c), isNull);
      expect(
        await c.read(secureStorageProvider).read(key: 'expiresAt'),
        isNull,
      );
    });
  });
}
