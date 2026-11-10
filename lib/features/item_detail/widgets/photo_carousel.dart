import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../../shared/widgets/item_photo_image.dart';
import '../item_detail_provider.dart';

/// Detay ekranının üstündeki kaydırılabilir fotoğraflar. Dokununca
/// [onOpen] o anki fotoğrafın sırasıyla çağrılır (tam ekran galeri).
class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({
    super.key,
    required this.itemId,
    required this.photos,
    required this.onOpen,
  });

  final int itemId;
  final List<ItemPhoto> photos;
  final ValueChanged<int> onOpen;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) {
      return const AspectRatio(
        aspectRatio: 4 / 3,
        child: ItemPhotoImage(photo: null),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => widget.onOpen(i),
              child: Hero(
                tag: itemPhotoHeroTag(widget.itemId, photos[i]),
                child: ItemPhotoImage(photo: photos[i]),
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: _Counter(text: '${_index + 1} / ${photos.length}'),
            ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
