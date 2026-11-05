import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/api/api_client.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/api_item_repository.dart';

/// İsteği kaydedip yola göre sabit JSON döndüren adaptör.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes, {this.status = 200});

  final Map<String, Object?> routes;
  final int status;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(routes[options.path] ?? {}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

(ApiItemRepository, _FakeAdapter) _repo(
  Map<String, Object?> routes, {
  int status = 200,
}) {
  final adapter = _FakeAdapter(routes, status: status);
  final client = ApiClient(baseUrl: 'http://api.test:5080')
    ..dio.httpClientAdapter = adapter;
  return (ApiItemRepository(client), adapter);
}

void main() {
  final item = mockItems.first;
  final itemJson = item.toJson()
    ..['photos'] = [
      {'id': 1, 'url': '/uploads/cuzdan.jpg', 'sortOrder': 0},
      {'id': 2, 'url': 'https://cdn.test/x.jpg', 'sortOrder': 1},
    ];

  test('liste isteği filtreleri sorgu parametresi olarak gönderir', () async {
    final (repo, adapter) = _repo({
      '/api/items': {
        'items': [itemJson],
        'page': 2,
        'pageSize': 10,
        'totalCount': 11,
      },
    });

    final res = await repo.getItems(
      type: ItemType.found,
      query: '  cüzdan ',
      categoryId: 2,
      locationId: 3,
      since: DateTime.utc(2026, 10, 1),
      page: 2,
    );

    expect(adapter.last!.queryParameters, {
      'type': 'found',
      'q': 'cüzdan',
      'categoryId': 2,
      'locationId': 3,
      'from': '2026-10-01T00:00:00.000Z',
      'page': 2,
      'pageSize': 10,
    });
    expect(res.items.single.title, item.title);
    expect(res.page, 2);
    expect(res.hasMore, isFalse);
  });

  test('boş filtreler gönderilmez', () async {
    final (repo, adapter) = _repo({
      '/api/items': {'items': [], 'page': 1, 'pageSize': 10, 'totalCount': 0},
    });

    await repo.getItems(query: '   ');
    expect(adapter.last!.queryParameters, {'page': 1, 'pageSize': 10});
  });

  test('göreli fotoğraf adresi API adresine göre mutlak yapılır', () async {
    final (repo, _) = _repo({'/api/items/1': itemJson});

    final res = await repo.getItem(1);
    expect(res.photos.map((p) => p.url), [
      'http://api.test:5080/uploads/cuzdan.jpg',
      'https://cdn.test/x.jpg',
    ]);
  });

  test('kategori ve bina listeleri', () async {
    final (repo, _) = _repo({
      '/api/categories': [for (final c in mockCategories.take(2)) c.toJson()],
      '/api/locations': [for (final l in mockLocations.take(3)) l.toJson()],
    });

    expect(await repo.getCategories(), mockCategories.take(2).toList());
    expect(await repo.getLocations(), mockLocations.take(3).toList());
  });

  test('sunucu hatası AppException olarak gelir', () async {
    final (repo, _) = _repo({}, status: 500);

    await expectLater(repo.getItems(), throwsA(isA<ServerException>()));
  });
}
