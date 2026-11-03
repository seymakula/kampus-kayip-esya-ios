import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// İlan fotoğrafı: mock veride asset, API'de ağ adresi (diskte önbelleğe
/// alınır). Fotoğraf yoksa veya yüklenemezse simge gösterir.
class ItemPhotoImage extends StatelessWidget {
  const ItemPhotoImage({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
  });

  final ItemPhoto? photo;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    if (photo == null) return const _Fallback(icon: Icons.image_outlined);

    if (photo.isAsset) {
      return Image.asset(
        photo.url,
        fit: fit,
        errorBuilder: (context, error, stack) =>
            const _Fallback(icon: Icons.broken_image_outlined),
      );
    }
    return CachedNetworkImage(
      imageUrl: photo.url,
      fit: fit,
      placeholder: (context, url) => const _Fallback(),
      errorWidget: (context, url, error) =>
          const _Fallback(icon: Icons.broken_image_outlined),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: icon == null
          ? null
          : Center(child: Icon(icon, color: colors.onSurfaceVariant)),
    );
  }
}
