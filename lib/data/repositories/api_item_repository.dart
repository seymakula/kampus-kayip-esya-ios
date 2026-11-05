import '../api/api_client.dart';
import '../models/models.dart';
import 'item_repository.dart';

/// Ortak Web API (BLM4581) üzerinden ilanlar.
///
/// | İstek                    | Yanıt                         |
/// | ------------------------ | ----------------------------- |
/// | `GET /api/items`         | `PagedResult<Item>`           |
/// | `GET /api/items/{id}`    | `Item`                        |
/// | `GET /api/categories`    | `Category[]`                  |
/// | `GET /api/locations`     | `Location[]`                  |
///
/// `/api/items` sorgu parametreleri: `type` (lost/found), `q`, `categoryId`,
/// `locationId`, `from` (ISO-8601, UTC), `page`, `pageSize`.
class ApiItemRepository implements ItemRepository {
  ApiItemRepository(this._client);

  final ApiClient _client;

  @override
  Future<PagedResult<Item>> getItems({
    ItemType? type,
    String? query,
    int? categoryId,
    int? locationId,
    DateTime? since,
    int page = 1,
    int pageSize = 10,
  }) {
    final q = query?.trim();
    return _client.get(
      '/api/items',
      query: {
        'type': ?type?.name,
        if (q != null && q.isNotEmpty) 'q': q,
        'categoryId': ?categoryId,
        'locationId': ?locationId,
        'from': ?since?.toUtc().toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
      parse: (data) =>
          PagedResult.fromJson(data! as Map<String, dynamic>, _parseItem),
    );
  }

  @override
  Future<Item> getItem(int id) =>
      _client.get('/api/items/$id', parse: _parseItem);

  @override
  Future<List<Category>> getCategories() => _client.get(
    '/api/categories',
    parse: (data) => [
      for (final c in data! as List)
        Category.fromJson(c as Map<String, dynamic>),
    ],
  );

  @override
  Future<List<Location>> getLocations() => _client.get(
    '/api/locations',
    parse: (data) => [
      for (final l in data! as List)
        Location.fromJson(l as Map<String, dynamic>),
    ],
  );

  /// Sunucu fotoğraf adresini göreli (`/uploads/x.jpg`) verebilir;
  /// ekranlar her zaman mutlak adres görür.
  Item _parseItem(Object? json) {
    final item = Item.fromJson(json! as Map<String, dynamic>);
    final base = Uri.parse(_client.dio.options.baseUrl);
    return item.copyWith(
      photos: [
        for (final p in item.photos)
          p.copyWith(url: base.resolve(p.url).toString()),
      ],
    );
  }
}
