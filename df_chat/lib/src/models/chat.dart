import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  Chat({
    this.id,
    required this.username,
    required this.chatName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  final int? id;
  final String username;
  @JsonKey(name: 'chat_name')
  final String chatName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
}

@JsonEnum(alwaysCreate: true)
enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('bot')
  bot,
}

@JsonSerializable()
class SourceDocument {
  SourceDocument({
    this.entryId,
    this.entryDate,
    required this.snippet,
    this.documentId,
    this.fileName,
    this.previewUrl,
    this.downloadUrl,
    this.chunkText,
    this.startIndex,
    this.endIndex,
  });

  factory SourceDocument.fromJson(Map<String, dynamic> json) =>
      _$SourceDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$SourceDocumentToJson(this);

  @JsonKey(name: 'entry_id')
  final int? entryId;
  @JsonKey(name: 'entry_date')
  final String? entryDate;
  final String snippet;

  /// Optional richer citation metadata for document-centric chats.
  @JsonKey(name: 'document_id')
  final int? documentId;

  @JsonKey(name: 'file_name')
  final String? fileName;

  @JsonKey(name: 'preview_url')
  final String? previewUrl;

  @JsonKey(name: 'download_url')
  final String? downloadUrl;

  @JsonKey(name: 'chunk_text')
  final String? chunkText;

  @JsonKey(name: 'start_index')
  final int? startIndex;

  @JsonKey(name: 'end_index')
  final int? endIndex;
}

@JsonSerializable()
class Message {
  Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.createdAt,
    List<SourceDocument>? sourceDocuments,
  }) : sourceDocuments = sourceDocuments ?? const [];

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  final int id;
  @JsonKey(name: 'chat_id')
  final int chatId;
  final MessageRole role;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'source_documents', defaultValue: <SourceDocument>[])
  final List<SourceDocument> sourceDocuments;
}

/// Represents a non-streaming user/bot message pair returned from the API.
@JsonSerializable()
class MessagePair {
  MessagePair({
    required this.userMessage,
    required this.botMessage,
  });

  factory MessagePair.fromJson(Map<String, dynamic> json) =>
      _$MessagePairFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePairToJson(this);

  @JsonKey(name: 'user_message')
  final Message userMessage;

  @JsonKey(name: 'bot_message')
  final Message botMessage;
}
