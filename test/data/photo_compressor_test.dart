import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/data/photos/photo_compressor.dart';

void main() {
  group('targetShortEdge (uzun kenar en fazla 1280)', () {
    test('iPhone yatay ve dikey fotoğrafı aynı ölçekte küçülür', () {
      // 4032×3024 → 1280×960
      expect(targetShortEdge(4032, 3024, 1280), 960);
      expect(targetShortEdge(3024, 4032, 1280), 960);
    });

    test('16:9 ve kare', () {
      expect(targetShortEdge(1920, 1080, 1280), 720);
      expect(targetShortEdge(3000, 3000, 1280), 1280);
    });

    test('zaten küçük fotoğraf büyütülmez', () {
      expect(targetShortEdge(800, 600, 1280), 600);
      expect(targetShortEdge(1280, 720, 1280), 720);
    });
  });

  group('jpegFileName', () {
    test('uzantı jpg olur, klasör yolu atılır', () {
      expect(jpegFileName('/private/var/tmp/IMG_0042.HEIC'), 'IMG_0042.jpg');
      expect(jpegFileName(r'C:\temp\foto.png'), 'foto.jpg');
      expect(jpegFileName('/tmp/a.jpeg'), 'a.jpg');
    });

    test('uzantısız ve gizli dosya adları', () {
      expect(jpegFileName('/tmp/kamera'), 'kamera.jpg');
      expect(jpegFileName('/tmp/.gizli'), '.gizli.jpg');
    });
  });
}
