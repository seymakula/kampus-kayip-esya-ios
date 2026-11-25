import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/item_card.dart';
import '../../search/search_providers.dart';
import '../create_item_draft.dart';
import '../create_item_screen.dart';
import '../device_services.dart';

/// 4. adım: bina (listeden ya da "Şu anki konumum" ile en yakını) ve önizleme.
class LocationStep extends ConsumerStatefulWidget {
  const LocationStep({super.key, required this.showErrors});

  final bool showErrors;

  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  var _locating = false;

  /// Konum alınamadığında gösterilen açıklama; kalıcı retse Ayarlar düğmesi.
  String? _note;
  var _offerSettings = false;

  Future<void> _pickFromList() async {
    final picked = await showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _BuildingSheet(),
    );
    if (picked != null) {
      ref.read(createItemDraftProvider.notifier).setLocation(picked);
      setState(() => _note = null);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _note = null;
      _offerSettings = false;
    });
    final result = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    String? note;
    var settings = false;
    switch (result) {
      case LocationFound(:final latitude, :final longitude):
        try {
          final buildings = await ref.read(locationsProvider.future);
          final nearest = nearestBuilding(latitude, longitude, buildings);
          if (nearest == null) {
            note = 'Binaların konumu henüz girilmemiş; listeden seçebilirsin.';
          } else {
            ref.read(createItemDraftProvider.notifier).setLocation(nearest);
            note = 'En yakın bina seçildi; gerekirse değiştirebilirsin.';
          }
        } catch (_) {
          note = 'Bina listesi yüklenemedi. Tekrar dene.';
        }
      case LocationDenied():
        note = 'Konum izni verilmedi; binayı listeden seçebilirsin.';
      case LocationDeniedForever():
        note = 'Konum izni kapalı. Ayarlar\'dan açabilir ya da listeden seçebilirsin.';
        settings = true;
      case LocationServiceOff():
        note = 'Konum servisleri kapalı; binayı listeden seçebilirsin.';
      case LocationUnavailable():
        note = 'Konum alınamadı; binayı listeden seçebilirsin.';
    }
    if (mounted) {
      setState(() {
        _locating = false;
        _note = note;
        _offerSettings = settings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createItemDraftProvider);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final theme = Theme.of(context);
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Konum', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          draft.type == ItemType.lost
              ? 'Eşyayı en son nerede gördün?'
              : 'Eşyayı nerede buldun?',
          style: TextStyle(color: p.muted),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: widget.showErrors && draft.location == null
                  ? p.lost
                  : p.line,
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(draft.location?.name ?? 'Bina seç'),
            subtitle: draft.location == null
                ? const Text('Listeden ara ya da konumunu kullan')
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickFromList,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: const Text('Şu anki konumum'),
        ),
        if (_note != null) ...[
          const SizedBox(height: 8),
          Text(_note!, style: TextStyle(color: p.muted, fontSize: 13)),
          if (_offerSettings)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    ref.read(locationServiceProvider).openSettings(),
                child: const Text('Ayarları aç'),
              ),
            ),
        ],
        const SizedBox(height: 24),
        Text('Önizleme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'İlanın görevli onayından sonra böyle görünecek.',
          style: TextStyle(color: p.muted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ItemCard(item: previewItem(draft, categories, DateTime.now())),
      ],
    );
  }
}

/// Aranabilir bina listesi (`GET /api/locations`).
class _BuildingSheet extends ConsumerStatefulWidget {
  const _BuildingSheet();

  @override
  ConsumerState<_BuildingSheet> createState() => _BuildingSheetState();
}

class _BuildingSheetState extends ConsumerState<_BuildingSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsProvider);
    final q = _query.trim().toLowerCase();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Bina ara',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: locations.when(
              data: (list) {
                final shown = [
                  for (final l in list)
                    if (q.isEmpty || l.name.toLowerCase().contains(q)) l,
                ];
                if (shown.isEmpty) {
                  return const Center(child: Text('Eşleşen bina yok.'));
                }
                return ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.apartment_outlined),
                    title: Text(shown[i].name),
                    onTap: () => Navigator.pop(context, shown[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(locationsProvider),
                  child: const Text('Binalar yüklenemedi. Tekrar dene'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
