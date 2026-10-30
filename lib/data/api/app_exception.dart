import 'package:dio/dio.dart';

/// Ekranların gördüğü tek hata türü. `DioException` veri katmanından dışarı
/// sızmaz; [AppException.fromDio] ile buna çevrilir.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Kullanıcıya gösterilecek Türkçe mesaj.
  final String message;

  factory AppException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const NetworkException(
          'Sunucu yanıt vermedi. Lütfen tekrar deneyin.',
        ),
        DioExceptionType.cancel => const NetworkException(
          'İstek iptal edildi.',
        ),
        _ => const NetworkException(
          'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.',
        ),
      };
    }

    final status = response.statusCode ?? 0;
    final problem = _ProblemDetails.tryParse(response.data);
    if (status == 401) {
      return const UnauthorizedException();
    }
    if (status == 400 && problem?.errors != null) {
      return ValidationException(
        problem!.errors!,
        message: problem.title ?? 'Girilen bilgileri kontrol edin.',
      );
    }
    return ServerException(
      status,
      problem?.detail ?? problem?.title ?? _defaultMessage(status),
    );
  }

  static String _defaultMessage(int status) => switch (status) {
    403 => 'Bu işlem için yetkiniz yok.',
    404 => 'Aradığınız kayıt bulunamadı.',
    409 => 'Bu işlem mevcut bir kayıtla çakışıyor.',
    >= 500 => 'Sunucuda bir hata oluştu. Lütfen daha sonra deneyin.',
    _ => 'Beklenmeyen bir hata oluştu ($status).',
  };

  @override
  String toString() => '$runtimeType: $message';
}

/// Sunucuya hiç ulaşılamadı (bağlantı yok, zaman aşımı).
final class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Sunucu 4xx/5xx döndü.
final class ServerException extends AppException {
  const ServerException(this.statusCode, super.message);

  final int statusCode;
}

/// 400 + ProblemDetails `errors`: alan adı → hata mesajları.
/// Form ekranları ilgili alanın altında gösterir.
final class ValidationException extends AppException {
  const ValidationException(
    this.errors, {
    String message = 'Girilen bilgileri kontrol edin.',
  }) : super(message);

  final Map<String, List<String>> errors;

  /// Alan adı büyük/küçük harf duyarsız aranır (`Email` / `email`).
  String? errorFor(String field) {
    final f = field.toLowerCase();
    for (final MapEntry(:key, :value) in errors.entries) {
      if (key.toLowerCase() == f && value.isNotEmpty) return value.first;
    }
    return null;
  }
}

/// 401: oturum yok veya süresi dolmuş.
final class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super('Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.');
}

/// ASP.NET Core `ProblemDetails` / `ValidationProblemDetails` gövdesi.
class _ProblemDetails {
  const _ProblemDetails({this.title, this.detail, this.errors});

  final String? title;
  final String? detail;
  final Map<String, List<String>>? errors;

  static _ProblemDetails? tryParse(Object? data) {
    if (data is! Map) return null;
    final rawErrors = data['errors'];
    Map<String, List<String>>? errors;
    if (rawErrors is Map) {
      errors = {
        for (final MapEntry(:key, :value) in rawErrors.entries)
          key.toString(): value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()],
      };
    }
    return _ProblemDetails(
      title: data['title'] as String?,
      detail: data['detail'] as String?,
      errors: errors,
    );
  }
}
