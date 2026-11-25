import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Yüklemeye hazır fotoğraf.
class CompressedPhoto {
  const CompressedPhoto({required this.bytes, required this.filename});

  final Uint8List bytes;
  final String filename;
}

/// Fotoğrafı yüklemeden önce küçültür. Testlerde sahtesi verilir; gerçek
/// sıkıştırma yalnızca telefonda çalışır.
abstract class PhotoCompressor {
  Future<CompressedPhoto> compress(String path);
}

/// Uzun kenarı en fazla [maxLongEdge] piksel, [quality] kaliteli JPEG.
/// EXIF (GPS konumu dahil) silinir; yön bilgisi pikselle uygulanır.
///
/// iPhone fotoğrafı (4032×3024, 3–5 MB) → 1280×960, yaklaşık 150–300 KB.
class JpegPhotoCompressor implements PhotoCompressor {
  const JpegPhotoCompressor({this.maxLongEdge = 1280, this.quality = 75});

  final int maxLongEdge;
  final int quality;

  @override
  Future<CompressedPhoto> compress(String path) async {
    final size = await _readSize(path);
    final edge = size == null
        // Boyut okunamazsa (ör. desteklenmeyen biçim) 4:3 varsayılır.
        ? (maxLongEdge * 3 / 4).round()
        : targetShortEdge(size.$1, size.$2, maxLongEdge);

    final bytes = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: edge,
      minHeight: edge,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Fotoğraf sıkıştırılamadı: $path');
    }
    return CompressedPhoto(bytes: bytes, filename: jpegFileName(path));
  }

  /// Dosyanın piksel boyutu; görüntü tamamen çözülmeden, başlığından okunur.
  static Future<(int, int)?> _readSize(String path) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromFilePath(path);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final size = (descriptor.width, descriptor.height);
      descriptor.dispose();
      buffer.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }
}

/// `flutter_image_compress` ölçeği `max(minWidth / w, minHeight / h)` olarak
/// hesaplar. İkisine de kısa kenarın hedefini verince ölçek uzun kenara göre
/// olur ve fotoğrafın yatay / dikey (EXIF yönü) olması sonucu değiştirmez.
/// Küçük fotoğraf büyütülmez.
int targetShortEdge(int width, int height, int maxLongEdge) {
  final longEdge = math.max(width, height);
  final shortEdge = math.min(width, height);
  if (longEdge <= maxLongEdge) return shortEdge;
  return (shortEdge * maxLongEdge / longEdge).round();
}

/// `IMG_0042.HEIC` → `IMG_0042.jpg` (çıktı her zaman JPEG).
String jpegFileName(String path) {
  final name = path.split(RegExp(r'[/\\]')).last;
  final dot = name.lastIndexOf('.');
  final base = dot > 0 ? name.substring(0, dot) : name;
  return '${base.isEmpty ? 'foto' : base}.jpg';
}
