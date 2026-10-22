import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// Kampüs binası. Koordinatlar "en yakın bina" ve harita için kullanılır.
@freezed
abstract class Location with _$Location {
  const factory Location({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
