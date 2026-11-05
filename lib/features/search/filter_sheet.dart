import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_filter.dart';
import 'search_providers.dart';

/// Kategori, bina ve tarih seçimi. "Uygula" ile seçilen filtreyi döndürür;
/// kapatılırsa `null`.
Future<SearchFilter?> showFilterSheet(
  BuildContext context,
  SearchFilter current,
) => showModalBottomSheet<SearchFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => FilterSheet(initial: current),
);

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final SearchFilter initial;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late SearchFilter _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final locations = ref.watch(locationsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text('Filtrele', style: Theme.of(context).textTheme.titleLarge),
                _Section(
                  title: 'Kategori',
                  child: _Choices(
                    value: categories.whenData(
                      (list) => [for (final c in list) (c.id, c.name)],
                    ),
                    selected: _draft.categoryId,
                    onSelected: (id) => setState(
                      () => _draft = _draft.copyWith(categoryId: () => id),
                    ),
                    onRetry: () => ref.invalidate(categoriesProvider),
                  ),
                ),
                _Section(
                  title: 'Bina',
                  child: _Choices(
                    value: locations.whenData(
                      (list) => [for (final l in list) (l.id, l.name)],
                    ),
                    selected: _draft.locationId,
                    onSelected: (id) => setState(
                      () => _draft = _draft.copyWith(locationId: () => id),
                    ),
                    onRetry: () => ref.invalidate(locationsProvider),
                  ),
                ),
                _Section(
                  title: 'Tarih',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in DateRange.values)
                        ChoiceChip(
                          label: Text(r.label),
                          selected: _draft.range == r,
                          onSelected: (_) => setState(
                            () => _draft = _draft.copyWith(range: r),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                        () => _draft = SearchFilter(
                          text: _draft.text,
                          type: _draft.type,
                        ),
                      ),
                      child: const Text('Sıfırla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _draft),
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// "Tümü" + listeden tek seçim. Liste yüklenirken / hata verirse ona göre.
class _Choices extends StatelessWidget {
  const _Choices({
    required this.value,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
  });

  final AsyncValue<List<(int, String)>> value;
  final int? selected;
  final ValueChanged<int?> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncValue(:final value?) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Tümü'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final (id, name) in value)
            ChoiceChip(
              label: Text(name),
              selected: selected == id,
              onSelected: (_) => onSelected(id),
            ),
        ],
      ),
      AsyncError() => Row(
        children: [
          const Expanded(child: Text('Liste yüklenemedi.')),
          TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
      _ => const Padding(
        padding: EdgeInsets.all(8),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    };
  }
}
