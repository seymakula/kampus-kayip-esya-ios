import '../models/models.dart';

/// Ekranlar yalnızca bu arayüzü bilir. Mock ve API uygulamaları arasında
/// geçiş `itemRepositoryProvider` içinde tek satırla yapılır.
abstract class ItemRepository {
  Future<PagedResult<Item>> getItems({
    ItemType? type,
    String? query,
    int? categoryId,
    int? locationId,
    int page = 1,
    int pageSize = 10,
  });

  Future<Item> getItem(int id);

  Future<List<Category>> getCategories();

  Future<List<Location>> getLocations();
}
