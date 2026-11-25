import '../api/api_client.dart';
import '../api/app_exception.dart';
import '../api/item_dto.dart';
import '../models/models.dart';
import 'item_repository.dart';

/// Ortak Web API (BLM4581) üzerinden ilanlar.
///
/// | İstek                    | Yanıt                         |
/// | ------------------------ | ----------------------------- |
/// | `GET /api/items`         | `{ items: ItemListDto[], page, pageSize, totalCount }` |
/// | `GET /api/items/{id}`    | `ItemDetailDto`               |
/// | `GET /api/categories`    | `Category[]`                  |
/// | `GET /api/locations`     | `Location[]`                  |
///
/// `/api/items` sorgu parametreleri: `type` (Lost/Found), `q`, `categoryId`,
/// `locationId`, `from` (ISO-8601, UTC), `page`, `pageSize` (en fazla 50).
/// İlan DTO'ları [ItemDto] ile modele çevrilir.
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
        'type': ?type?.apiValue,
        if (q != null && q.isNotEmpty) 'q': q,
        'categoryId': ?categoryId,
        'locationId': ?locationId,
        'from': ?since?.toUtc().toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
      parse: (data) => _parse(
        () => PagedResult.fromJson(
          data! as Map<String, dynamic>,
          (json) => ItemDto.fromList(json! as Map<String, dynamic>, _photoUrl),
        ),
      ),
    );
  }

  @override
  Future<Item> getItem(int id) => _client.get(
    '/api/items/$id',
    parse: (data) => _parse(
      () => ItemDto.fromDetail(data! as Map<String, dynamic>, _photoUrl),
    ),
  );

  @override
  Future<List<Category>> getCategories() => _client.get(
    '/api/categories',
    parse: (data) => _parse(
      () => [
        for (final c in data! as List)
          Category.fromJson(c as Map<String, dynamic>),
      ],
    ),
  );

  @override
  Future<List<Location>> getLocations() => _client.get(
    '/api/locations',
    parse: (data) => _parse(
      () => [
        for (final l in data! as List)
          Location.fromJson(l as Map<String, dynamic>),
      ],
    ),
  );

  /// Sunucu fotoğraf adresini göreli (`/uploads/x.jpg`) verebilir;
  /// ekranlar her zaman mutlak adres görür.
  String _photoUrl(String url) =>
      Uri.parse(_client.dio.options.baseUrl).resolve(url).toString();

  /// Beklenmeyen biçimde gelen yanıt uygulamayı çökertmesin.
  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw _unexpected;
    } on TypeError {
      throw _unexpected;
    }
  }

  static const _unexpected = ServerException(
    200,
    'Sunucudan beklenmeyen bir yanıt alındı.',
  );
}
