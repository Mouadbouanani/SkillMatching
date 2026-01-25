import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String fromId;
  final String? toId;
  final String text;
  final String type; // TEXT, IMAGE, FILE
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.fromId,
    this.toId,
    required this.text,
    this.type = 'TEXT',
    this.isRead = false,
    required this.sentAt,
    this.readAt,
  });

  // Alias for compatibility with existing UI code if needed
  String get senderId => fromId;
  String get content => text;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      fromId: json['fromId'] ?? json['senderId'] ?? '',
      toId: json['toId'],
      text: json['text'] ?? json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      isRead: json['isRead'] ?? false,
      sentAt: json['sentAt'] != null 
          ? DateTime.tryParse(json['sentAt']) ?? DateTime.now() 
          : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'fromId': fromId,
      if (toId != null) 'toId': toId,
      'text': text,
      'type': type,
      'isRead': isRead,
      'sentAt': sentAt.toIso8601String(),
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, conversationId, fromId, toId, text, type, isRead, sentAt, readAt];
}
