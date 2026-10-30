import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// İlan fotoğrafı: mock veride asset, API'de ağ adresi. Fotoğraf yoksa veya
/// yüklenemezse simge gösterir. Hafta 3'te ağ görselleri önbelleğe alınacak
/// (cached_network_image); yalnızca bu dosya değişir.
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

    Widget error(BuildContext context, Object error, StackTrace? stack) =>
        const _Fallback(icon: Icons.broken_image_outlined);

    return photo.isAsset
        ? Image.asset(photo.url, fit: fit, errorBuilder: error)
        : Image.network(
            photo.url,
            fit: fit,
            errorBuilder: error,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const _Fallback(),
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
