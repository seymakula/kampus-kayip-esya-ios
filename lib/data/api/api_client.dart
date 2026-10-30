import 'package:dio/dio.dart';

import '../../app/config.dart';
import 'app_exception.dart';

/// Uygulamadaki tek `Dio` örneği. Repository'ler bunu kullanır ve
/// [DioException] yerine her zaman [AppException] fırlatır.
class ApiClient {
  ApiClient({
    String baseUrl = apiBase,
    List<Interceptor> interceptors = const [],
    Dio? dio,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: apiTimeout,
               sendTimeout: apiTimeout,
               receiveTimeout: apiTimeout,
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           ) {
    this.dio.interceptors.addAll(interceptors);
  }

  final Dio dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? data) parse,
  }) => _send(() => dio.get<Object?>(path, queryParameters: query), parse);

  Future<T> post<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) => _send(() => dio.post<Object?>(path, data: body), parse);

  Future<T> put<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
  }) => _send(() => dio.put<Object?>(path, data: body), parse);

  Future<void> delete(String path) =>
      _send(() => dio.delete<Object?>(path), (_) {});

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(Object? data) parse,
  ) async {
    try {
      final response = await request();
      return parse(response.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
