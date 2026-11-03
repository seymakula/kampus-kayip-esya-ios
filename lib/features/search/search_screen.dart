import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../shared/widgets/paged_item_list_view.dart';
import 'filter_sheet.dart';
import 'search_filter.dart';
import 'search_providers.dart';

/// Yazmayı bitirmeden her harfte istek atılmasın.
const searchDebounce = Duration(milliseconds: 400);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _text = TextEditingController(
    text: ref.read(searchFilterProvider).text,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {}); // temizle düğmesi
    _debounce?.cancel();
    _debounce = Timer(
      searchDebounce,
      () => ref.read(searchFilterProvider.notifier).setText(value),
    );
  }

  void _clearText() {
    _debounce?.cancel();
    _text.clear();
    setState(() {});
    ref.read(searchFilterProvider.notifier).setText('');
  }

  Future<void> _openFilters(SearchFilter current) async {
    final result = await showFilterSheet(context, current);
    if (result != null) ref.read(searchFilterProvider.notifier).apply(result);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchFilterProvider.notifier);
    final results = searchResultsProvider(filter);
    final filterCount = filter.sheetFilterCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Ara')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    onChanged: _onTextChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Eşya, renk, marka…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _text.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Temizle',
                              icon: const Icon(Icons.close),
                              onPressed: _clearText,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Filtrele',
                  onPressed: () => _openFilters(filter),
                  icon: Badge(
                    isLabelVisible: filterCount > 0,
                    label: Text('$filterCount'),
                    child: const Icon(Icons.tune),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ItemType?>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: null, label: Text('Tümü')),
                  ButtonSegment(value: ItemType.lost, label: Text('Kayıp')),
                  ButtonSegment(value: ItemType.found, label: Text('Bulunan')),
                ],
                selected: {filter.type},
                onSelectionChanged: (s) => notifier.setType(s.first),
              ),
            ),
          ),
          if (filterCount > 0) _ActiveFilters(filter: filter),
          Expanded(
            child: PagedItemListView(
              value: ref.watch(results),
              onRefresh: () => ref.read(results.notifier).refresh(),
              onLoadMore: () => ref.read(results.notifier).loadMore(),
              onRetry: () => ref.invalidate(results),
              emptyIcon: Icons.search_off,
              emptyTitle: 'Sonuç bulunamadı',
              emptyMessage: 'Farklı bir kelime dene ya da filtreleri azalt.',
            ),
          ),
        ],
      ),
    );
  }
}

/// Seçili kategori / bina / tarih; çarpıyla tek tek kaldırılır.
class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.filter});

  final SearchFilter filter;

  String _name<T>(
    AsyncValue<List<T>> list,
    int id,
    int Function(T) idOf,
    String Function(T) nameOf,
  ) {
    for (final x in list.value ?? <T>[]) {
      if (idOf(x) == id) return nameOf(x);
    }
    return '…';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchFilterProvider.notifier);
    final categoryId = filter.categoryId;
    final locationId = filter.locationId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (categoryId != null)
              InputChip(
                label: Text(
                  _name(
                    ref.watch(categoriesProvider),
                    categoryId,
                    (Category c) => c.id,
                    (c) => c.name,
                  ),
                ),
                onDeleted: notifier.clearCategory,
              ),
            if (locationId != null)
              InputChip(
                avatar: const Icon(Icons.place_outlined, size: 18),
                label: Text(
                  _name(
                    ref.watch(locationsProvider),
                    locationId,
                    (Location l) => l.id,
                    (l) => l.name,
                  ),
                ),
                onDeleted: notifier.clearLocation,
              ),
            if (filter.range != DateRange.all)
              InputChip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: Text(filter.range.label),
                onDeleted: notifier.clearRange,
              ),
          ],
        ),
      ),
    );
  }
}
