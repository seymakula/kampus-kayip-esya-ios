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
  isOwner: json['isOwner'] as bool? ?? false,
  ownerName: json['ownerName'] as String?,
  isAtOffice: json['isAtOffice'] as bool? ?? false,
  verificationQuestion: json['verificationQuestion'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
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
  'isOwner': instance.isOwner,
  'ownerName': instance.ownerName,
  'isAtOffice': instance.isAtOffice,
  'verificationQuestion': instance.verificationQuestion,
  'rejectionReason': instance.rejectionReason,
  'photos': instance.photos.map((e) => e.toJson()).toList(),
};

const _$ItemTypeEnumMap = {ItemType.lost: 'Lost', ItemType.found: 'Found'};

const _$ItemStatusEnumMap = {
  ItemStatus.pending: 'Pending',
  ItemStatus.published: 'Published',
  ItemStatus.rejected: 'Rejected',
  ItemStatus.resolved: 'Resolved',
  ItemStatus.archived: 'Archived',
};
