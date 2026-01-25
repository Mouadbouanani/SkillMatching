import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String matchId;
  final String participant1Id;
  final String participant2Id;
  final DateTime? lastMessageAt;
  final String? lastMessageContent; 
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.matchId,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessageAt,
    this.lastMessageContent,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? '',
      participant1Id: json['participant1Id'] ?? '',
      participant2Id: json['participant2Id'] ?? '',
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.tryParse(json['lastMessageAt']) 
          : null,
      lastMessageContent: json['lastMessageContent'], // Not always in backend model but useful
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  String getOtherParticipantId(String myUserId) {
    return participant1Id == myUserId ? participant2Id : participant1Id;
  }

  @override
  List<Object?> get props => [id, matchId, participant1Id, participant2Id, lastMessageAt, createdAt];
}
