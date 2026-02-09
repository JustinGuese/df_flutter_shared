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
  });

  factory SourceDocument.fromJson(Map<String, dynamic> json) =>
      _$SourceDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$SourceDocumentToJson(this);

  @JsonKey(name: 'entry_id')
  final int? entryId;
  @JsonKey(name: 'entry_date')
  final String? entryDate;
  final String snippet;
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
