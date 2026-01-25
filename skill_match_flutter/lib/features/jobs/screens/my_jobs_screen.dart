import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/job_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../bloc/job_bloc.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(LoadMyJobsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<JobBloc>().add(LoadMyJobsEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-job'),
        icon: const Icon(Icons.add),
        label: const Text('Créer'),
        backgroundColor: AppColors.clientColor,
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.status == JobStateStatus.error) {
            return ErrorState(
              message: state.errorMessage ?? 'Erreur',
              onRetry: () => context.read<JobBloc>().add(LoadMyJobsEvent()),
            );
          }

          final jobs = state.myJobs;

          if (jobs.isEmpty) {
            return EmptyState(
              icon: Icons.work_outline,
              title: 'Aucun job créé',
              subtitle: 'Créez votre premier job pour trouver des talents',
              action: GradientButton(
                onPressed: () => context.push('/create-job'),
                colors: [AppColors.clientColor, AppColors.primary],
                child: const Text('Créer un job'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<JobBloc>().add(LoadMyJobsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MyJobCard(job: jobs[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MyJobCard extends StatelessWidget {
  final Job job;

  const _MyJobCard({required this.job});

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
              Expanded(
                child: Text(
                  job.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            job.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Budget and date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.formattedBudget,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(job.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/jobs/${job.id}'),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Voir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/jobs/${job.id}/applications'),
                  icon: const Icon(Icons.people_outline, size: 18),
                  label: const Text('Candidats'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.clientColor,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          if (job.status == JobStatus.open) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                       context.pushNamed(
                         'edit-job', 
                         pathParameters: {'jobId': job.id!},
                         extra: job,
                       );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le job ?'),
        content: const Text('Cette action est irréversible. Voulez-vous vraiment supprimer ce job ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<JobBloc>().add(DeleteJobEvent(job.id!));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (job.status) {
      case JobStatus.open:
        color = AppColors.success;
        break;
      case JobStatus.inProgress:
        color = AppColors.warning;
        break;
      case JobStatus.completed:
        color = AppColors.info;
        break;
      case JobStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        job.statusLabel,
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
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
