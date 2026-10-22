// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemPhoto _$ItemPhotoFromJson(Map<String, dynamic> json) => _ItemPhoto(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ItemPhotoToJson(_ItemPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'sortOrder': instance.sortOrder,
    };
