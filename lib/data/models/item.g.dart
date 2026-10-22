// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$ItemTypeEnumMap, json['type']),
  status: $enumDecode(_$ItemStatusEnumMap, json['status']),
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  category: Category.fromJson(json['category'] as Map<String, dynamic>),
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  eventDate: DateTime.parse(json['eventDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  ownerId: (json['ownerId'] as num).toInt(),
  verificationQuestion: json['verificationQuestion'] as String?,
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => ItemPhoto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ItemPhoto>[],
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$ItemTypeEnumMap[instance.type]!,
  'status': _$ItemStatusEnumMap[instance.status]!,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category.toJson(),
  'location': instance.location.toJson(),
  'eventDate': instance.eventDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'ownerId': instance.ownerId,
  'verificationQuestion': instance.verificationQuestion,
  'photos': instance.photos.map((e) => e.toJson()).toList(),
};

const _$ItemTypeEnumMap = {ItemType.lost: 'lost', ItemType.found: 'found'};

const _$ItemStatusEnumMap = {
  ItemStatus.pending: 'pending',
  ItemStatus.published: 'published',
  ItemStatus.rejected: 'rejected',
  ItemStatus.resolved: 'resolved',
  ItemStatus.archived: 'archived',
};
