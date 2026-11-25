import '../models/models.dart';

/// Yeni ilan (web `ItemWriteRequest`). Durum gönderilmez; sunucu her yeni
/// ilanı "Onay bekliyor" açar.
class NewItem {
  const NewItem({
    required this.type,
    required this.title,
    required this.categoryId,
    required this.locationId,
    required this.eventDate,
    required this.description,
    this.verificationQuestion,
  });

  final ItemType type;
  final String title;
  final int categoryId;
  final int locationId;
  final DateTime eventDate;
  final String description;

  /// Yalnızca "Bulundu" ilanında.
  final String? verificationQuestion;

  Map<String, dynamic> toJson() => {
    'type': type.apiValue,
    'title': title,
    'categoryId': categoryId,
    'locationId': locationId,
    'eventDate': eventDate.toUtc().toIso8601String(),
    'description': description,
    'verificationQuestion': verificationQuestion,
  };
}

/// Ekranlar yalnızca bu arayüzü bilir. Mock ve API uygulamaları arasında
/// geçiş `itemRepositoryProvider` içinde tek satırla yapılır.
abstract class ItemRepository {
  Future<PagedResult<Item>> getItems({
    ItemType? type,
    String? query,
    int? categoryId,
    int? locationId,

    /// Yalnızca bu tarihten sonra kaybolan / bulunan ilanlar.
    DateTime? since,
    int page = 1,
    int pageSize = 10,
  });

  Future<Item> getItem(int id);

  Future<List<Category>> getCategories();

  Future<List<Location>> getLocations();

  /// `POST /api/items`; açılan ilanı (Onay bekliyor) döndürür.
  Future<Item> createItem(NewItem item);

  /// `POST /api/items/{id}/photos` (multipart, alan adı `files`, en fazla 5).
  /// [onProgress] 0–1 arası gönderim oranı.
  ///
  /// Hafta 5 (Barış): yüklemeden önce sıkıştırma (uzun kenar 1280, JPEG ~75)
  /// buraya eklenecek; ekran bu imzayı kullanmaya devam eder.
  Future<Item> uploadPhotos(
    int itemId,
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  });
}
