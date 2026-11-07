import '../mock/mock_data.dart';
import '../models/models.dart';
import 'auth_repository.dart';

/// `USE_MOCK=true` ile çalışır: form geçerliyse her bilgiyle giriş yapılır.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  User _user = mockCurrentUser;

  AuthSession get _session => AuthSession(
    token: 'mock-token',
    expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    return _session;
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String studentNo,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    _user = User(
      id: 'mock-yeni',
      fullName: fullName,
      email: email,
      studentNo: studentNo,
    );
    return _session;
  }

  @override
  Future<User> me() async {
    await Future<void>.delayed(latency);
    return _user;
  }
}
