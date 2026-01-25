import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/job_application_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../messaging/bloc/messaging_bloc.dart';
import '../bloc/job_bloc.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;

  const JobApplicationsScreen({super.key, required this.jobId});

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(LoadJobApplicationsEvent(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidatures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<JobBloc>().add(
              LoadJobApplicationsEvent(widget.jobId),
            ),
          ),
        ],
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.status == JobStateStatus.error) {
            return ErrorState(
              message: state.errorMessage ?? 'Erreur',
              onRetry: () => context.read<JobBloc>().add(
                LoadJobApplicationsEvent(widget.jobId),
              ),
            );
          }

          final applications = state.jobApplications;
          final hasAcceptedApplication = applications.any((a) => a.status == ApplicationStatus.accepted);

          if (applications.isEmpty) {
            return const Center(
              child: Text('Aucune candidature pour le moment'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<JobBloc>().add(
                LoadJobApplicationsEvent(widget.jobId),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ApplicationCard(
                    application: applications[index],
                    hasAnyAccepted: hasAcceptedApplication,
                    onAccept: () {
                      context.read<JobBloc>().add(UpdateApplicationStatusEvent(
                        applicationId: applications[index].id!,
                        status: ApplicationStatus.accepted,
                        jobId: widget.jobId,
                      ));
                    },
                    onReject: () {
                      context.read<JobBloc>().add(UpdateApplicationStatusEvent(
                        applicationId: applications[index].id!,
                        status: ApplicationStatus.rejected,
                        jobId: widget.jobId,
                      ));
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final bool hasAnyAccepted;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.hasAnyAccepted,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLight,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.providerColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prestataire ID: ${application.providerId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(application.appliedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          const SizedBox(height: 16),

          // Proposed rate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tarif proposé',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${application.proposedRate} MAD',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cover letter
          if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Message',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                application.coverLetter!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],

          // Actions (only if pending)
          if (application.status == ApplicationStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                if (!hasAnyAccepted) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      onPressed: onAccept,
                      height: 48,
                      colors: [AppColors.success, AppColors.secondary],
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 8),
                          Text('Accepter'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          // View profile & Message
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => context.push('/profile/${application.providerId}'),
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('Profil'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    final myUserId = authState.user?.firebaseUid ?? authState.user?.id;
                    if (myUserId != null) {
                      context.read<MessagingBloc>().add(StartConversationEvent(
                        matchId: application.jobId,
                        participant1Id: myUserId,
                        participant2Id: application.providerId,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conversation initialisée. Allez dans l\'onglet Messages.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    switch (application.status) {
      case ApplicationStatus.pending:
        color = AppColors.warning;
        break;
      case ApplicationStatus.reviewed:
        color = AppColors.info;
        break;
      case ApplicationStatus.accepted:
        color = AppColors.success;
        break;
      case ApplicationStatus.rejected:
        color = AppColors.error;
        break;
      case ApplicationStatus.cancelled:
        color = AppColors.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        application.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
