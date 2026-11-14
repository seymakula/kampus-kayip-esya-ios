import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../shared/widgets/async_value_view.dart';
import '../../shared/widgets/item_photo_image.dart';
import 'item_detail_provider.dart';

/// Tam ekran fotoğraf galerisi: yana kaydırarak geçiş, iki parmakla veya
/// çift dokunarak yakınlaştırma. Yakınlaştırılmışken sayfa kaymaz.
class PhotoGalleryScreen extends ConsumerStatefulWidget {
  const PhotoGalleryScreen({
    super.key,
    required this.itemId,
    this.initialIndex = 0,
  });

  final int itemId;
  final int initialIndex;

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  PageController? _controller;
  int _index = 0;
  bool _zoomed = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Fotoğraf sayısı ilan yüklenince belli olur; sıra o zaman sınırlanır.
  PageController _controllerFor(int count) {
    return _controller ??= () {
      _index = widget.initialIndex.clamp(0, count - 1);
      return PageController(initialPage: _index);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(itemDetailProvider(widget.itemId));
    final count = item.value?.photos.length ?? 0;
    // Başlıktaki sayaç da doğru sırayı göstersin diye gövdeden önce kurulur.
    final controller = count > 0 ? _controllerFor(count) : null;

    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const CloseButton(),
          title: count > 1 ? Text('${_index + 1} / $count') : null,
        ),
        body: AsyncValueView(
          value: item,
          isEmpty: (item) => item.photos.isEmpty,
          emptyIcon: Icons.hide_image_outlined,
          emptyTitle: 'Fotoğraf yok',
          emptyMessage: 'Bu ilana fotoğraf eklenmemiş.',
          onRetry: () => ref.invalidate(itemDetailProvider(widget.itemId)),
          data: (item) => PageView.builder(
            controller: controller,
            physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: item.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => ZoomablePhoto(
              heroTag: itemPhotoHeroTag(item.id, item.photos[i]),
              photo: item.photos[i],
              onZoomChanged: (zoomed) {
                if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomablePhoto extends StatefulWidget {
  const ZoomablePhoto({
    super.key,
    required this.photo,
    required this.heroTag,
    required this.onZoomChanged,
  });

  final ItemPhoto photo;
  final String heroTag;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ZoomablePhoto> createState() => _ZoomablePhotoState();
}

class _ZoomablePhotoState extends State<ZoomablePhoto> {
  static const _doubleTapScale = 2.5;

  final _transform = TransformationController();
  Offset _tapPosition = Offset.zero;

  bool get _zoomed => _transform.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();
    _transform.addListener(() => widget.onZoomChanged(_zoomed));
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// Yakınsa uzaklaştır; değilse dokunulan noktaya yakınlaştır.
  void _onDoubleTap() {
    if (_zoomed) {
      _transform.value = Matrix4.identity();
      return;
    }
    const s = _doubleTapScale;
    _transform.value = Matrix4.diagonal3Values(s, s, 1)
      ..setTranslationRaw(
        -_tapPosition.dx * (s - 1),
        -_tapPosition.dy * (s - 1),
        0,
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _tapPosition = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transform,
        maxScale: 4,
        child: SizedBox.expand(
          child: Hero(
            tag: widget.heroTag,
            child: ItemPhotoImage(photo: widget.photo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
