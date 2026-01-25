import 'package:equatable/equatable.dart';
import '../models/conversation.dart';
import '../models/message.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversationsEvent extends MessagingEvent {
  final String userId;
  const LoadConversationsEvent(this.userId);
}

class LoadMessagesEvent extends MessagingEvent {
  final String conversationId;
  const LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends MessagingEvent {
  final String conversationId;
  final String content;
  final String senderId;
  const SendMessageEvent({
    required this.conversationId,
    required this.content,
    required this.senderId,
  });
}

class StartConversationEvent extends MessagingEvent {
  final String matchId;
  final String participant1Id;
  final String participant2Id;
  
  const StartConversationEvent({
    required this.matchId,
    required this.participant1Id,
    required this.participant2Id,
  });
}
