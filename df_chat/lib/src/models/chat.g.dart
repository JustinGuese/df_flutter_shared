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
      documentId: (json['document_id'] as num?)?.toInt(),
      fileName: json['file_name'] as String?,
      previewUrl: json['preview_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      chunkText: json['chunk_text'] as String?,
      startIndex: (json['start_index'] as num?)?.toInt(),
      endIndex: (json['end_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SourceDocumentToJson(SourceDocument instance) =>
    <String, dynamic>{
      'entry_id': instance.entryId,
      'entry_date': instance.entryDate,
      'snippet': instance.snippet,
      'document_id': instance.documentId,
      'file_name': instance.fileName,
      'preview_url': instance.previewUrl,
      'download_url': instance.downloadUrl,
      'chunk_text': instance.chunkText,
      'start_index': instance.startIndex,
      'end_index': instance.endIndex,
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

MessagePair _$MessagePairFromJson(Map<String, dynamic> json) => MessagePair(
  userMessage: Message.fromJson(json['user_message'] as Map<String, dynamic>),
  botMessage: Message.fromJson(json['bot_message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessagePairToJson(MessagePair instance) =>
    <String, dynamic>{
      'user_message': instance.userMessage,
      'bot_message': instance.botMessage,
    };
