import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../data/models/models.dart';
import '../../shared/utils/date_format.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/item_card.dart';
import 'item_detail_provider.dart';
import 'widgets/photo_carousel.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemDetailProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('İlan Detayı')),
      body: AsyncValueView(
        value: item,
        onRetry: () => ref.invalidate(itemDetailProvider(itemId)),
        data: (item) => RefreshIndicator(
          onRefresh: () async {
            // Hata durumu ekranda gösterilir; burada fırlatılmaz.
            try {
              ref.invalidate(itemDetailProvider(itemId));
              await ref.read(itemDetailProvider(itemId).future);
            } catch (_) {}
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PhotoCarousel(
                itemId: item.id,
                photos: item.photos,
                onOpen: (i) =>
                    context.push(AppRoutes.itemPhotos(item.id, index: i)),
              ),
              _Details(item: item),
            ],
          ),
        ),
      ),
      bottomNavigationBar: switch (item) {
        // Yenilenirken eski veri durur; düğme kaybolmaz.
        AsyncValue(:final value?) when value.status == ItemStatus.published =>
          _ClaimBar(item: value),
        _ => null,
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lost = item.type == ItemType.lost;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ItemTypeBadge(type: item.type),
              if (item.status != ItemStatus.published)
                Text(
                  item.status.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: item.category.name,
          ),
          _InfoRow(
            icon: Icons.place_outlined,
            label: lost ? 'Kaybolduğu yer' : 'Bulunduğu yer',
            value: item.location.name,
          ),
          _InfoRow(
            icon: Icons.event_outlined,
            label: lost ? 'Kaybolma tarihi' : 'Bulunma tarihi',
            value:
                '${formatDateTime(item.eventDate)} · '
                '${formatRelative(item.eventDate)}',
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: 'İlan tarihi',
            value: formatDateTime(item.createdAt),
          ),
          const Divider(height: 32),
          Text('Açıklama', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            item.description.isEmpty
                ? 'Açıklama eklenmemiş.'
                : item.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: item.description.isEmpty ? colors.onSurfaceVariant : null,
            ),
          ),
          if (item.verificationQuestion != null) ...[
            const SizedBox(height: 16),
            Card(
              color: colors.secondaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.verified_user_outlined,
                  color: colors.onSecondaryContainer,
                ),
                title: Text(
                  'Bu eşyayı talep ederken bulan kişinin sorduğu doğrulama '
                  'sorusunu yanıtlaman gerekecek.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bulunan ilanda "Bu benim", kayıp ilanında "Ben buldum".
class _ClaimBar extends StatelessWidget {
  const _ClaimBar({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final kind = item.type == ItemType.found
        ? ClaimKind.owner
        : ClaimKind.finder;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: FilledButton.icon(
          icon: Icon(
            kind == ClaimKind.owner
                ? Icons.front_hand_outlined
                : Icons.volunteer_activism_outlined,
          ),
          label: Text(kind.label),
          // Hafta 6 (Şeyma): talep ekranına git (doğrulama sorusu, cevap).
          onPressed: () => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Talep gönderme yakında eklenecek.'),
              ),
            ),
        ),
      ),
    );
  }
}
