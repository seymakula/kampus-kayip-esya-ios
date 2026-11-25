import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../utils/date_format.dart';
import 'item_photo_image.dart';
import 'tag_badge.dart';

export 'tag_badge.dart' show ItemTypeBadge;

/// Listelerdeki ilan kartı (web `.item-card`): üstte 16:10 kapak fotoğrafı ve
/// sol üstte tür etiketi; altta başlık, bina · tarih ve kategori çipi.
/// Ana sayfa, arama sonuçları ve "İlanlarım" aynı kartı kullanır.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, this.onTap, this.now});

  final Item item;
  final VoidCallback? onTap;

  /// Göreli tarih için "şimdi"; testlerde sabitlenir.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final meta = theme.textTheme.bodySmall?.copyWith(
      color: p.muted,
      fontSize: 13,
    );
    final cover = item.coverPhoto;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cover != null)
                    ColoredBox(
                      color: p.surface2,
                      child: ItemPhotoImage(photo: cover),
                    )
                  else
                    ColoredBox(
                      color: typeTint(p, item.type),
                      child: Center(
                        child: PlaceholderTag(
                          type: item.type,
                          icon: categoryIcon(item.category.icon),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: ItemTypeBadge(
                      type: item.type,
                      hole: cover != null ? p.surface2 : typeTint(p, item.type),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 15, color: p.muted),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          item.location.name,
                          style: meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(' · ', style: meta),
                      Text(
                        formatRelative(item.eventDate, now: now),
                        style: meta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CategoryChip(label: item.category.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
