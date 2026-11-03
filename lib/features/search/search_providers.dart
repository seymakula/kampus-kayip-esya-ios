import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../data/models/models.dart';
import '../../shared/paging/paged_items.dart';
import 'search_filter.dart';

/// "Şimdi"; tarih filtresi testlerde sabit bir güne göre hesaplansın diye.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Filtre paneli için kategori ve bina listeleri (İlan aç ekranı da kullanır).
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(itemRepositoryProvider).getCategories(),
);

final locationsProvider = FutureProvider<List<Location>>(
  (ref) => ref.watch(itemRepositoryProvider).getLocations(),
);

/// Ara ekranının güncel seçimleri. Sekme değişince korunur.
class SearchFilterNotifier extends Notifier<SearchFilter> {
  @override
  SearchFilter build() => const SearchFilter();

  void setText(String text) => state = state.copyWith(text: text.trim());

  void setType(ItemType? type) => state = state.copyWith(type: () => type);

  /// Filtre panelinden dönen kategori, bina ve tarih seçimleri.
  void apply(SearchFilter filter) =>
      state = filter.copyWith(text: state.text, type: () => state.type);

  void clearCategory() => state = state.copyWith(categoryId: () => null);

  void clearLocation() => state = state.copyWith(locationId: () => null);

  void clearRange() => state = state.copyWith(range: DateRange.all);
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilter>(
      SearchFilterNotifier.new,
    );

/// Bir filtrenin sonuçları. Filtre değişince eski sonuçlar bellekten atılır.
class SearchResultsNotifier extends PagedItemsNotifier {
  SearchResultsNotifier(this.filter);

  final SearchFilter filter;

  @override
  Future<PagedResult<Item>> fetchPage(int page) => ref
      .read(itemRepositoryProvider)
      .getItems(
        type: filter.type,
        query: filter.text.isEmpty ? null : filter.text,
        categoryId: filter.categoryId,
        locationId: filter.locationId,
        since: filter.range.since(ref.read(clockProvider)()),
        page: page,
        pageSize: PagedItemsNotifier.pageSize,
      );
}

final searchResultsProvider = AsyncNotifierProvider.autoDispose
    .family<SearchResultsNotifier, PagedItems, SearchFilter>(
      SearchResultsNotifier.new,
    );
