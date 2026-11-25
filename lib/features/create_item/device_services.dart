import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/models.dart';

/// Kamera ve galeri. Testlerde sahtesiyle değiştirilir.
abstract class PhotoSource {
  /// Çekilen fotoğrafın yolu; vazgeçilirse `null`.
  Future<String?> takePhoto();

  /// Seçilen fotoğrafların yolları (en fazla [limit]).
  Future<List<String>> pickFromGallery(int limit);
}

class ImagePickerPhotoSource implements PhotoSource {
  final _picker = ImagePicker();

  @override
  Future<String?> takePhoto() async =>
      (await _picker.pickImage(source: ImageSource.camera))?.path;

  @override
  Future<List<String>> pickFromGallery(int limit) async {
    if (limit <= 0) return const [];
    final files = limit == 1
        ? [?await _picker.pickImage(source: ImageSource.gallery)]
        : await _picker.pickMultiImage(limit: limit);
    return [for (final f in files) f.path];
  }
}

final photoSourceProvider = Provider<PhotoSource>(
  (ref) => ImagePickerPhotoSource(),
);

/// Konum izninin ve isteğin sonucu.
sealed class LocationResult {
  const LocationResult();
}

final class LocationFound extends LocationResult {
  const LocationFound(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// Kullanıcı izni bu sefer vermedi; tekrar sorulabilir.
final class LocationDenied extends LocationResult {
  const LocationDenied();
}

/// Kalıcı ret: yalnızca Ayarlar'dan açılabilir.
final class LocationDeniedForever extends LocationResult {
  const LocationDeniedForever();
}

final class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

final class LocationUnavailable extends LocationResult {
  const LocationUnavailable();
}

/// Cihazın konumu. Testlerde sahtesiyle değiştirilir.
abstract class LocationService {
  Future<LocationResult> current();
  Future<void> openSettings();
}

/// İzin akışı: checkPermission → gerekirse requestPermission → konum.
class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationServiceOff();
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return switch (permission) {
        LocationPermission.denied => const LocationDenied(),
        LocationPermission.deniedForever => const LocationDeniedForever(),
        _ => await _position(),
      };
    } catch (_) {
      return const LocationUnavailable();
    }
  }

  Future<LocationResult> _position() async {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LocationFound(p.latitude, p.longitude);
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);

/// Konuma en yakın bina (haversine, metre). Koordinatı girilmemiş binalar
/// atlanır; hiçbirinde koordinat yoksa `null` (rehber 8.8).
Location? nearestBuilding(double lat, double lng, List<Location> all) {
  double rad(double d) => d * pi / 180;
  double dist(Location l) {
    const r = 6371000.0;
    final dLat = rad(l.latitude! - lat);
    final dLng = rad(l.longitude! - lng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(lat)) * cos(rad(l.latitude!)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * atan2(sqrt(a), sqrt(1 - a));
  }

  final withCoords = all.where((l) => l.hasCoordinates).toList();
  if (withCoords.isEmpty) return null;
  return withCoords.reduce((a, b) => dist(a) <= dist(b) ? a : b);
}
