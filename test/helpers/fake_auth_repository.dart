import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/auth_repository.dart';

/// Hataları ve çağrı sayılarını testten denetlenebilen repository.
class FakeAuthRepository implements AuthRepository {
  AppException? loginError;
  AppException? registerError;
  Object? meError;
  int meCalls = 0;

  final session = AuthSession(
    token: 'yeni-token',
    expiresAt: DateTime.utc(2099),
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (loginError case final e?) throw e;
    return session;
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String studentNo,
    required String password,
  }) async {
    if (registerError case final e?) throw e;
    return session;
  }

  @override
  Future<User> me() async {
    meCalls++;
    if (meError case final e?) throw e;
    return mockCurrentUser;
  }
}
