import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/app_exception.dart';
import '../api/item_dto.dart';
import '../models/models.dart';
import '../photos/photo_compressor.dart';
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
  ApiItemRepository(
    this._client, {
    this.compressor = const JpegPhotoCompressor(),
  });

  final ApiClient _client;

  /// Yüklemeden önce fotoğrafı küçültür; testlerde sahtesi verilir.
  final PhotoCompressor compressor;

  /// İlerlemenin sıkıştırmaya ayrılan payı; kalanı ağ gönderimi.
  static const _compressShare = 0.2;

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

  @override
  Future<Item> createItem(NewItem item) => _client.post(
    '/api/items',
    body: item.toJson(),
    parse: (data) => _parse(
      () => ItemDto.fromDetail(data! as Map<String, dynamic>, _photoUrl),
    ),
  );

  @override
  Future<Item> uploadPhotos(
    int itemId,
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  }) async {
    // Sırayla sıkıştırılır: aynı anda beş büyük fotoğraf belleği zorlamasın.
    final files = <MultipartFile>[];
    for (final (i, path) in filePaths.indexed) {
      files.add(await _prepare(path));
      onProgress?.call(_compressShare * (i + 1) / filePaths.length);
    }

    final form = FormData.fromMap({'files': files});
    return _client.send(
      () => _client.dio.post<Object?>(
        '/api/items/$itemId/photos',
        data: form,
        onSendProgress: (sent, total) => onProgress?.call(
          _compressShare +
              (1 - _compressShare) * (total > 0 ? sent / total : 0),
        ),
      ),
      (data) => _parse(
        () => ItemDto.fromDetail(data! as Map<String, dynamic>, _photoUrl),
      ),
    );
  }

  /// Sıkıştırılmış JPEG; sıkıştırma başarısız olursa özgün dosya gönderilir
  /// (yükleme sırf bu yüzden durmasın, sunucu boyutu yine denetler).
  Future<MultipartFile> _prepare(String path) async {
    try {
      final photo = await compressor.compress(path);
      return MultipartFile.fromBytes(
        photo.bytes,
        filename: photo.filename,
        contentType: DioMediaType('image', 'jpeg'),
      );
    } catch (_) {
      return MultipartFile.fromFile(path);
    }
  }

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
