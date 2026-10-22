// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: (json['id'] as num).toInt(),
  claimId: (json['claimId'] as num).toInt(),
  senderId: (json['senderId'] as num).toInt(),
  content: json['content'] as String,
  sentAt: DateTime.parse(json['sentAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'claimId': instance.claimId,
  'senderId': instance.senderId,
  'content': instance.content,
  'sentAt': instance.sentAt.toIso8601String(),
  'isRead': instance.isRead,
};
