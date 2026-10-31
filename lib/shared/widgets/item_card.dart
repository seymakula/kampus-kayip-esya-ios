import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../utils/date_format.dart';
import 'item_photo_image.dart';

/// Listelerdeki ilan kartı: kapak fotoğrafı, tür rozeti, başlık, bina ve tarih.
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
    final colors = theme.colorScheme;
    final meta = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: 88,
                  child: ItemPhotoImage(photo: item.coverPhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ItemTypeBadge(type: item.type),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.category.name,
                            style: meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location.name,
                            style: meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRelative(item.eventDate, now: now),
                          style: meta,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kayıp" / "Bulundu" rozeti; renkler [AppColors]'tan.
class ItemTypeBadge extends StatelessWidget {
  const ItemTypeBadge({super.key, required this.type});

  final ItemType type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      ItemType.lost => AppColors.lost,
      ItemType.found => AppColors.found,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          type.label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
