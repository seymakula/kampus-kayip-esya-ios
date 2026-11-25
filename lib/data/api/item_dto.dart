import '../models/models.dart';

/// Web API'nin ilan yanıtlarını uygulama modeline çevirir.
///
/// API iki biçim döndürür (web `Dtos/ItemDtos.cs`):
/// - `ItemListDto` (liste): kategori ve bina düz alan (`categoryName`,
///   `locationName`), tek kapak fotoğrafı (`coverPhotoUrl`), açıklama yok.
/// - `ItemDetailDto` (detay): ek olarak açıklama, sahiplik (`isOwner`,
///   `ownerName`), doğrulama sorusu, ret sebebi ve tüm fotoğraflar (`photoUrls`).
///
/// [photoUrl] göreli fotoğraf adresini mutlak yapar.
abstract final class ItemDto {
  static Item fromList(
    Map<String, dynamic> json,
    String Function(String) photoUrl,
  ) => _base(json, photoUrl, [
    if (json['coverPhotoUrl'] case final String url) url,
  ]);

  static Item fromDetail(
    Map<String, dynamic> json,
    String Function(String) photoUrl,
  ) {
    final item = _base(json, photoUrl, [
      for (final url in json['photoUrls'] as List? ?? const []) url as String,
    ]);
    return item.copyWith(
      description: json['description'] as String? ?? '',
      isOwner: json['isOwner'] as bool? ?? false,
      ownerName: json['ownerName'] as String?,
      isAtOffice: json['isAtOffice'] as bool? ?? false,
      verificationQuestion: json['verificationQuestion'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  static Item _base(
    Map<String, dynamic> json,
    String Function(String) photoUrl,
    List<String> photos,
  ) => Item(
    id: json['id'] as int,
    type: enumFromApi(ItemType.values, json['type']),
    status: enumFromApi(ItemStatus.values, json['status']),
    title: json['title'] as String? ?? '',
    category: Category(
      id: json['categoryId'] as int,
      name: json['categoryName'] as String? ?? '',
      icon: json['categoryIcon'] as String?,
    ),
    // Liste yalnızca birleşik adı verir ("Bina – Kat"); filtre için id yeterli.
    location: Location(
      id: json['locationId'] as int,
      building: json['locationName'] as String? ?? '',
    ),
    eventDate: DateTime.parse(json['eventDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    photos: [
      for (final (i, url) in photos.indexed)
        ItemPhoto(id: i, url: photoUrl(url), sortOrder: i),
    ],
  );
}
