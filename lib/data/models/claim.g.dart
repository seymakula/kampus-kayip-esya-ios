// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Claim _$ClaimFromJson(Map<String, dynamic> json) => _Claim(
  id: (json['id'] as num).toInt(),
  itemId: (json['itemId'] as num).toInt(),
  itemTitle: json['itemTitle'] as String,
  kind: $enumDecode(_$ClaimKindEnumMap, json['kind']),
  status: $enumDecode(_$ClaimStatusEnumMap, json['status']),
  claimantId: (json['claimantId'] as num).toInt(),
  claimantName: json['claimantName'] as String,
  answer: json['answer'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ClaimToJson(_Claim instance) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'itemTitle': instance.itemTitle,
  'kind': _$ClaimKindEnumMap[instance.kind]!,
  'status': _$ClaimStatusEnumMap[instance.status]!,
  'claimantId': instance.claimantId,
  'claimantName': instance.claimantName,
  'answer': instance.answer,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ClaimKindEnumMap = {
  ClaimKind.owner: 'owner',
  ClaimKind.finder: 'finder',
};

const _$ClaimStatusEnumMap = {
  ClaimStatus.pending: 'pending',
  ClaimStatus.approved: 'approved',
  ClaimStatus.rejected: 'rejected',
};
