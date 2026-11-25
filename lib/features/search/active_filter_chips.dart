import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import 'search_filter.dart';
import 'search_providers.dart';

/// Seçili kategori / bina / tarih; çarpıyla tek tek kaldırılır.
/// Ara ekranı ve ana sayfa kendi filtre provider'ıyla kullanır.
class ActiveFilterChips extends ConsumerWidget {
  const ActiveFilterChips({
    super.key,
    required this.filter,
    required this.notifier,
  });

  final SearchFilter filter;
  final SearchFilterNotifier notifier;

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
