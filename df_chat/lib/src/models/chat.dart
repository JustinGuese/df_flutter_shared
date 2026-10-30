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

  factory SourceDocument.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as String? ??
                    json['title'] as String? ??
                    json['heading'] as String? ??
                    json['description'] as String? ?? '';
    final downloadUrl = json['download_url'] as String? ??
                        json['source_url'] as String? ??
                        json['url'] as String? ??
                        json['preview_url'] as String?;
    return SourceDocument(
      entryId: (json['entry_id'] as num?)?.toInt(),
      entryDate: json['entry_date'] as String?,
      snippet: snippet,
      documentId: (json['document_id'] as num?)?.toInt(),
      fileName: json['file_name'] as String?,
      previewUrl: json['preview_url'] as String?,
      downloadUrl: downloadUrl,
      chunkText: json['chunk_text'] as String?,
      startIndex: (json['start_index'] as num?)?.toInt(),
      endIndex: (json['end_index'] as num?)?.toInt(),
    );
  }

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

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId?.toString() ?? '1') ?? rawId.hashCode;

    final rawChatId = json['chat_id'] ?? json['chatId'] ?? 1;
    final chatId = rawChatId is num
        ? rawChatId.toInt()
        : int.tryParse(rawChatId.toString()) ?? 1;

    final roleStr = json['role'] as String? ?? 'bot';
    final role = roleStr == 'user' ? MessageRole.user : MessageRole.bot;

    final content = json['content'] as String? ?? json['text'] as String? ?? '';

    DateTime createdAt;
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    if (rawCreatedAt is num) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt.toInt());
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    List<SourceDocument> sourceDocuments = [];
    final rawDocs = json['source_documents'] ?? json['sourceDocuments'];
    if (rawDocs is List) {
      sourceDocuments = rawDocs
          .map((e) => SourceDocument.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Message(
      id: id,
      chatId: chatId,
      role: role,
      content: content,
      createdAt: createdAt,
      sourceDocuments: sourceDocuments,
    );
  }

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
  MessagePair({required this.userMessage, required this.botMessage});

  factory MessagePair.fromJson(Map<String, dynamic> json) =>
      _$MessagePairFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePairToJson(this);

  @JsonKey(name: 'user_message')
  final Message userMessage;

  @JsonKey(name: 'bot_message')
  final Message botMessage;
}
