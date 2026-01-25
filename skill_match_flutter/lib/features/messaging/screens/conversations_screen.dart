import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/profile_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/repository/profile_repository.dart';
import '../../profile/bloc/profile_event.dart'; // Import pour LoadProfileEvent si besoin
import '../bloc/messaging_bloc.dart';
import '../models/conversation.dart';
import '../../../core/di/service_locator.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      // Utiliser firebaseUid si dispo, sinon id
      final userId = user.firebaseUid ?? user.id;
      context.read<MessagingBloc>().add(LoadConversationsEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        builder: (context, state) {
          if (state.status == MessagingStatus.loading && state.conversations.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.status == MessagingStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Erreur de chargement'),
            );
          }

          if (state.conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'Aucune conversation',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conversation = state.conversations[index];
              return ConversationTile(conversation: conversation);
            },
          );
        },
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const ConversationTile({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final myUserId = authState.user?.firebaseUid ?? authState.user?.id ?? '';
    final otherUserId = conversation.getOtherParticipantId(myUserId);

    // On utilise un FutureBuilder pour charger le profil de l'autre participant
    // Idéalement, on utiliserait un Cache ou un Store centralisé pour ne pas recharger à chaque fois
    return FutureBuilder<Profile?>(
      future: getIt<ProfileRepository>().getProfile(otherUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Si le profil n'est pas trouvé ou erreur, afficher l'UID raccourci
          final fallbackName = 'Utilisateur ${otherUserId.length > 5 ? otherUserId.substring(0, 5) : otherUserId}';
          return _buildTile(context, null, fallbackName, otherUserId);
        }

        final profile = snapshot.data;
        final name = profile?.displayName ?? 'Utilisateur';
        return _buildTile(context, profile, name, otherUserId);
      },
    );
  }

  Widget _buildTile(BuildContext context, Profile? profile, String name, String otherUserId) {
    return GestureDetector(
      onTap: () {
        context.push('/chat/${conversation.id}', extra: {
          'otherUserId': otherUserId,
          'otherUserName': name,
        });
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: (profile != null && profile.profilePictureUrl != null) 
                  ? NetworkImage(profile.profilePictureUrl!) 
                  : null,
              child: (profile == null || profile.profilePictureUrl == null)
                  ? Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatDate(conversation.lastMessageAt!),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessageContent ?? 'Nouvelle conversation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd/MM').format(date);
  }
}

