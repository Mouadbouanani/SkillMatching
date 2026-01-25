import 'package:equatable/equatable.dart';
import '../models/conversation.dart';
import '../models/message.dart';

enum MessagingStatus { initial, loading, loaded, error }

class MessagingState extends Equatable {
  final MessagingStatus status;
  final List<Conversation> conversations;
  final List<Message> messages; // Messages de la conversation active
  final String? errorMessage;
  final bool isSending;

  const MessagingState({
    this.status = MessagingStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.errorMessage,
    this.isSending = false,
  });

  MessagingState copyWith({
    MessagingStatus? status,
    List<Conversation>? conversations,
    List<Message>? messages,
    String? errorMessage,
    bool? isSending,
  }) {
    return MessagingState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [status, conversations, messages, errorMessage, isSending];
}
