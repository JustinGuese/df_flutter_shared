// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String,
  chatName: json['chat_name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'chat_name': instance.chatName,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

SourceDocument _$SourceDocumentFromJson(Map<String, dynamic> json) =>
    SourceDocument(
      entryId: (json['entry_id'] as num?)?.toInt(),
      entryDate: json['entry_date'] as String?,
      snippet: json['snippet'] as String,
    );

Map<String, dynamic> _$SourceDocumentToJson(SourceDocument instance) =>
    <String, dynamic>{
      'entry_id': instance.entryId,
      'entry_date': instance.entryDate,
      'snippet': instance.snippet,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  chatId: (json['chat_id'] as num).toInt(),
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  sourceDocuments:
      (json['source_documents'] as List<dynamic>?)
          ?.map((e) => SourceDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chat_id': instance.chatId,
  'role': _$MessageRoleEnumMap[instance.role]!,
  'content': instance.content,
  'created_at': instance.createdAt.toIso8601String(),
  'source_documents': instance.sourceDocuments,
};

const _$MessageRoleEnumMap = {MessageRole.user: 'user', MessageRole.bot: 'bot'};
