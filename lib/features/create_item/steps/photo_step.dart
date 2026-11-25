import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../create_item_draft.dart';
import '../device_services.dart';

/// 2. adım: kamera veya galeriden en fazla 5 fotoğraf; sil, sürükleyerek sırala.
class PhotoStep extends ConsumerWidget {
  const PhotoStep({super.key});

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _camera(BuildContext context, WidgetRef ref) async {
    try {
      final path = await ref.read(photoSourceProvider).takePhoto();
      if (path != null) {
        ref.read(createItemDraftProvider.notifier).addPhotos([path]);
      }
    } catch (_) {
      // Simülatörde kamera yok; kamera izni reddedilmiş de olabilir.
      if (context.mounted) {
        _message(context, 'Kamera kullanılamıyor; galeriden seçebilirsin.');
      }
    }
  }

  Future<void> _gallery(BuildContext context, WidgetRef ref) async {
    final room = maxPhotos - ref.read(createItemDraftProvider).photos.length;
    try {
      final paths = await ref.read(photoSourceProvider).pickFromGallery(room);
      final added = ref.read(createItemDraftProvider.notifier).addPhotos(paths);
      if (added < paths.length && context.mounted) {
        _message(context, 'En fazla $maxPhotos fotoğraf eklenebilir.');
      }
    } catch (_) {
      if (context.mounted) {
        _message(
          context,
          'Galeriye erişilemedi. Ayarlar\'dan izin verebilirsin.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(createItemDraftProvider.select((d) => d.photos));
    final notifier = ref.read(createItemDraftProvider.notifier);
    final p = context.palette;
    final full = photos.length >= maxPhotos;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Fotoğraflar', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'İsteğe bağlı ama eşyanın tanınmasını çok kolaylaştırır. '
          'İlk fotoğraf kapak olur; sırayı sürükleyerek değiştirebilirsin.',
          style: TextStyle(color: p.muted),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: full ? null : () => _camera(context, ref),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Kamera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: full ? null : () => _gallery(context, ref),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeri'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${photos.length}/$maxPhotos fotoğraf',
          style: TextStyle(color: p.muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: photos.isEmpty
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.surface,
                    border: Border.all(color: p.line),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: p.muted,
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: photos.length,
                  onReorderItem: notifier.movePhoto,
                  itemBuilder: (context, i) =>
                      ReorderableDelayedDragStartListener(
                        key: ValueKey(photos[i]),
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _Thumb(
                            path: photos[i],
                            cover: i == 0,
                            onRemove: () => notifier.removePhoto(i),
                          ),
                        ),
                      ),
                ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.cover,
    required this.onRemove,
  });

  final String path;
  final bool cover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox.square(
      dimension: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: p.surface2,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    Icon(Icons.broken_image_outlined, color: p.muted),
              ),
            ),
          ),
          if (cover)
            Positioned(
              left: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    'KAPAK',
                    style: TextStyle(
                      color: p.onAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 2,
            top: 2,
            child: IconButton.filledTonal(
              tooltip: 'Fotoğrafı kaldır',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
