import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_photo.freezed.dart';
part 'item_photo.g.dart';

/// API'de [url] mutlak adrestir; mock veride `assets/mock/...` yoludur.
@freezed
abstract class ItemPhoto with _$ItemPhoto {
  const ItemPhoto._();

  const factory ItemPhoto({
    required int id,
    required String url,
    @Default(0) int sortOrder,
  }) = _ItemPhoto;

  bool get isAsset => url.startsWith('assets/');

  factory ItemPhoto.fromJson(Map<String, dynamic> json) =>
      _$ItemPhotoFromJson(json);
}
