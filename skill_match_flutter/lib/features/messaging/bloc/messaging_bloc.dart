import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../repository/messaging_repository.dart';
import 'messaging_event.dart';
import 'messaging_state.dart';

export 'messaging_event.dart';
export 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingRepository _messagingRepository;

  MessagingBloc(this._messagingRepository) : super(const MessagingState()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<StartConversationEvent>(_onStartConversation);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading));
    
    try {
      final conversations = await _messagingRepository.getUserConversations(event.userId);
      emit(state.copyWith(
        status: MessagingStatus.loaded,
        conversations: conversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessagingStatus.error,
        errorMessage: 'Erreur lors du chargement des conversations',
      ));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading));
    
    try {
      final messages = await _messagingRepository.getConversationMessages(event.conversationId);
      emit(state.copyWith(
        status: MessagingStatus.loaded,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessagingStatus.error,
        errorMessage: 'Erreur lors du chargement des messages',
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(isSending: true));
    
    try {
      final message = await _messagingRepository.sendMessage(
        conversationId: event.conversationId,
        senderId: event.senderId,
        content: event.content,
      );
      
      // Add message to current list
      final currentMessages = List.of(state.messages);
      currentMessages.add(message);
      
      emit(state.copyWith(
        isSending: false,
        messages: currentMessages,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: 'Erreur lors de l\'envoi du message',
      ));
    }
  }

  Future<void> _onStartConversation(
    StartConversationEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading));
    
    try {
      final conversation = await _messagingRepository.createConversation(
        matchId: event.matchId,
        participant1Id: event.participant1Id,
        participant2Id: event.participant2Id,
      );
      
      final currentConversations = List.of(state.conversations);
      if (!currentConversations.any((c) => c.id == conversation.id)) {
        currentConversations.insert(0, conversation);
      }
      
      emit(state.copyWith(
        status: MessagingStatus.loaded,
        conversations: currentConversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessagingStatus.error,
        errorMessage: 'Erreur: ${e.toString()}',
      ));
    }
  }
}
