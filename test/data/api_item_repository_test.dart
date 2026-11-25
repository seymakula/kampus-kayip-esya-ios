import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/api/api_client.dart';
import 'package:kampus_kayip_esya/data/api/app_exception.dart';
import 'package:kampus_kayip_esya/data/mock/mock_data.dart';
import 'package:kampus_kayip_esya/data/models/models.dart';
import 'package:kampus_kayip_esya/data/repositories/api_item_repository.dart';
import 'package:kampus_kayip_esya/data/repositories/item_repository.dart';

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
  // Web'in gerçek yanıt biçimleri (Dtos/ItemDtos.cs; yerel API'den alınan örnek).
  const listJson = {
    'id': 7,
    'type': 'Found',
    'status': 'Published',
    'title': 'Siyah deri cüzdan',
    'categoryId': 3,
    'categoryName': 'Cüzdan',
    'categoryIcon': 'bi-wallet2',
    'locationId': 3,
    'locationName': 'Merkezi Derslik – Amfi',
    'eventDate': '2026-11-20T00:00:00Z',
    'createdAt': '2026-11-20T10:15:00Z',
    'coverPhotoUrl': '/uploads/items/7/a.jpg',
  };
  const detailJson = {
    ...listJson,
    'description': 'Amfinin arka sıralarında buldum.',
    'isAtOffice': false,
    'ownerName': 'Ayşe Y.',
    'isOwner': true,
    'verificationQuestion': 'Kart hangi bankanın?',
    'rejectionReason': null,
    'photoUrls': ['/uploads/items/7/a.jpg', 'https://cdn.test/x.jpg'],
  };

  test('liste isteği filtreleri sorgu parametresi olarak gönderir', () async {
    final (repo, adapter) = _repo({
      '/api/items': {
        'items': [listJson],
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
      'type': 'Found',
      'q': 'cüzdan',
      'categoryId': 2,
      'locationId': 3,
      'from': '2026-10-01T00:00:00.000Z',
      'page': 2,
      'pageSize': 10,
    });
    final item = res.items.single;
    expect(item.title, 'Siyah deri cüzdan');
    expect(item.type, ItemType.found);
    expect(item.status, ItemStatus.published);
    expect(
      item.category,
      const Category(id: 3, name: 'Cüzdan', icon: 'bi-wallet2'),
    );
    expect(item.location.name, 'Merkezi Derslik – Amfi');
    expect(item.eventDate, DateTime.utc(2026, 11, 20));
    expect(item.coverPhoto!.url, 'http://api.test:5080/uploads/items/7/a.jpg');
    expect(item.description, isEmpty);
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
    final (repo, _) = _repo({'/api/items/7': detailJson});

    final res = await repo.getItem(7);
    expect(res.photos.map((p) => p.url), [
      'http://api.test:5080/uploads/items/7/a.jpg',
      'https://cdn.test/x.jpg',
    ]);
    expect(res.description, 'Amfinin arka sıralarında buldum.');
    expect(res.isOwner, isTrue);
    expect(res.ownerName, 'Ayşe Y.');
    expect(res.verificationQuestion, 'Kart hangi bankanın?');
  });

  test('kategori ve bina listeleri', () async {
    final (repo, _) = _repo({
      '/api/categories': [for (final c in mockCategories.take(2)) c.toJson()],
      '/api/locations': [
        {
          'id': 8,
          'building': 'Güvenlik / Kayıp Eşya Bürosu',
          'floorOrRoom': null,
          'latitude': null,
          'longitude': null,
        },
      ],
    });

    expect(await repo.getCategories(), mockCategories.take(2).toList());
    expect(
      (await repo.getLocations()).single.name,
      'Güvenlik / Kayıp Eşya Bürosu',
    );
  });

  test('sunucu hatası AppException olarak gelir', () async {
    final (repo, _) = _repo({}, status: 500);

    await expectLater(repo.getItems(), throwsA(isA<ServerException>()));
  });

  test('beklenmeyen biçim çökme yerine anlamlı hata verir', () async {
    final (repo, _) = _repo({
      '/api/items/1': {...detailJson, 'type': 'Kayip'},
    });

    await expectLater(repo.getItem(1), throwsA(isA<ServerException>()));
  });

  test('ilan aç: doğru uca web ItemWriteRequest gövdesi gider', () async {
    final (repo, adapter) = _repo({'/api/items': detailJson});

    final created = await repo.createItem(
      NewItem(
        type: ItemType.found,
        title: 'Siyah deri cüzdan',
        categoryId: 3,
        locationId: 3,
        eventDate: DateTime.utc(2026, 11, 20, 9),
        description: 'Amfinin arka sıralarında buldum.',
        verificationQuestion: 'Kart hangi bankanın?',
      ),
    );

    expect(adapter.last!.method, 'POST');
    expect(adapter.last!.path, '/api/items');
    expect(adapter.last!.data, {
      'type': 'Found',
      'title': 'Siyah deri cüzdan',
      'categoryId': 3,
      'locationId': 3,
      'eventDate': '2026-11-20T09:00:00.000Z',
      'description': 'Amfinin arka sıralarında buldum.',
      'verificationQuestion': 'Kart hangi bankanın?',
    });
    expect(created.id, 7);
  });

  test('fotoğraflar multipart "files" alanıyla yüklenir', () async {
    final dir = Directory.systemTemp.createTempSync('foto');
    addTearDown(() => dir.deleteSync(recursive: true));
    final a = File('${dir.path}/a.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF]);
    final b = File('${dir.path}/b.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF]);
    final (repo, adapter) = _repo({'/api/items/7/photos': detailJson});

    final progress = <double>[];
    await repo.uploadPhotos(7, [a.path, b.path], onProgress: progress.add);

    final form = adapter.last!.data as FormData;
    expect(adapter.last!.path, '/api/items/7/photos');
    expect(form.files.map((f) => f.key), ['files', 'files']);
    expect(form.files.map((f) => f.value.filename), ['a.jpg', 'b.jpg']);
  });
}
