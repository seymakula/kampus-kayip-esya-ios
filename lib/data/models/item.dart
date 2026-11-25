import 'package:freezed_annotation/freezed_annotation.dart';

import 'category.dart';
import 'enums.dart';
import 'item_photo.dart';
import 'location.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
abstract class Item with _$Item {
  const Item._();

  const factory Item({
    required int id,
    required ItemType type,
    required ItemStatus status,
    required String title,
    @Default('') String description,
    required Category category,
    required Location location,
    required DateTime eventDate,
    required DateTime createdAt,

    /// Bakan kişi ilanın sahibi mi (API detayda verir; sahibin kimliği verilmez).
    @Default(false) bool isOwner,

    /// Sahibin kısaltılmış adı ("Ayşe Y."); yalnızca detayda.
    String? ownerName,

    /// Eşya kayıp eşya bürosuna teslim edildi mi.
    @Default(false) bool isAtOffice,

    /// Yalnızca "Bulundu" ilanlarında; API yalnızca sahibine ve görevliye verir.
    String? verificationQuestion,

    /// Görevlinin ret sebebi; yalnızca sahibine görünür.
    String? rejectionReason,
    @Default(<ItemPhoto>[]) List<ItemPhoto> photos,
  }) = _Item;

  ItemPhoto? get coverPhoto => photos.isEmpty ? null : photos.first;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
