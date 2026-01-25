import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MessagingRepository {
  final ApiClient _apiClient;

  MessagingRepository(this._apiClient);

  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final response = await _apiClient.getUserConversations(userId);
      if (response.data == null) return [];
      final List data = response.data;
      return data.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Message>> getConversationMessages(String conversationId) async {
    try {
      final response = await _apiClient.getConversationMessages(conversationId);
      if (response.data == null) return [];
      final List data = response.data;
      return data.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String type = 'TEXT',
  }) async {
    try {
      final response = await _apiClient.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        type: type,
      );
      return Message.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Conversation> createConversation({
    required String matchId,
    required String participant1Id,
    required String participant2Id,
  }) async {
    try {
      final response = await _apiClient.createConversation(
        matchId: matchId,
        participant1Id: participant1Id,
        participant2Id: participant2Id,
      );
      return Conversation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
