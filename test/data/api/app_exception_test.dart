import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';

final _req = RequestOptions(path: '/api/items');

DioException _withResponse(int status, [Object? data]) => DioException(
  requestOptions: _req,
  type: DioExceptionType.badResponse,
  response: Response(requestOptions: _req, statusCode: status, data: data),
);

void main() {
  test('bağlantı hatası ve zaman aşımı NetworkException olur', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      final e = AppException.fromDio(
        DioException(requestOptions: _req, type: type),
      );
      expect(e, isA<NetworkException>(), reason: '$type');
    }
  });

  test('401 UnauthorizedException olur', () {
    expect(
      AppException.fromDio(_withResponse(401)),
      isA<UnauthorizedException>(),
    );
  });

  test('400 + errors ValidationException olur, alan hatası okunur', () {
    final e = AppException.fromDio(
      _withResponse(400, {
        'title': 'One or more validation errors occurred.',
        'status': 400,
        'errors': {
          'Email': ['Okul e-postası gerekli.'],
          'Password': ['En az 8 karakter.', 'Rakam içermeli.'],
        },
      }),
    );
    expect(e, isA<ValidationException>());
    final v = e as ValidationException;
    expect(v.errors['Password'], hasLength(2));
    expect(v.errorFor('email'), 'Okul e-postası gerekli.');
    expect(v.errorFor('studentNo'), isNull);
  });

  test('diğer durumlar ServerException; ProblemDetails mesajı kullanılır', () {
    final withDetail = AppException.fromDio(
      _withResponse(409, {
        'title': 'Conflict',
        'detail': 'Bu ilana zaten talep gönderdiniz.',
      }),
    );
    expect(withDetail, isA<ServerException>());
    expect((withDetail as ServerException).statusCode, 409);
    expect(withDetail.message, 'Bu ilana zaten talep gönderdiniz.');

    final noBody = AppException.fromDio(_withResponse(500, '<html>'));
    expect(noBody, isA<ServerException>());
    expect(noBody.message, contains('Sunucuda bir hata'));
  });
}
