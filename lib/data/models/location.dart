import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// Kampüs binası (web `LocationDto`). Koordinatlar "en yakın bina" ve harita
/// için kullanılır; web'de henüz girilmemiş olabilir.
@freezed
abstract class Location with _$Location {
  const Location._();

  const factory Location({
    required int id,
    required String building,
    String? floorOrRoom,
    double? latitude,
    double? longitude,
  }) = _Location;

  /// Ekranda görünen ad; web'deki `LocationName` ile aynı biçim.
  String get name =>
      floorOrRoom == null ? building : '$building – $floorOrRoom';

  bool get hasCoordinates => latitude != null && longitude != null;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
