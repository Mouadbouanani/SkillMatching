import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/job_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/job_bloc.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(LoadJobDetailEvent(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isProvider = authState.user?.isProvider ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du job'),
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
                LoadJobDetailEvent(widget.jobId),
              ),
            );
          }

          final job = state.selectedJob;
          if (job == null) {
            return const EmptyState(
              icon: Icons.work_off_outlined,
              title: 'Job non trouvé',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Job header
                _buildHeader(context, job),
                const SizedBox(height: 16),

                // Budget and details
                _buildDetailsCard(context, job),
                const SizedBox(height: 16),

                // Description
                _buildDescriptionCard(context, job),
                const SizedBox(height: 16),

                // Required skills
                if (job.requiredSkills.isNotEmpty)
                  _buildSkillsCard(context, job),

                const SizedBox(height: 24),

                // Action button (for providers)
                // Action button (for providers)
                if (isProvider)
                  if (job.status == JobStatus.open)
                    _ApplyButton(job: job)
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            'Les candidatures pour ce job sont closes',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Job job) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(job),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (job.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.category!.name,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(job.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Job job) {
    return Row(
      children: [
        Expanded(
          child: _DetailItem(
            icon: Icons.monetization_on,
            label: 'Budget',
            value: job.formattedBudget,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DetailItem(
            icon: Icons.location_on,
            label: 'Lieu',
            value: job.location ?? 'Non spécifié',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DetailItem(
            icon: Icons.calendar_today,
            label: 'Deadline',
            value: job.deadline != null
                ? DateFormat('dd/MM/yy').format(job.deadline!)
                : 'Flexible',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(BuildContext context, Job job) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context, Job job) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Compétences requises',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.requiredSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill.skillName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (skill.requiredLevel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Niv. ${skill.requiredLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Job job) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
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

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final Job job;

  const _ApplyButton({required this.job});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _showApplyForm = false;
  final _coverLetterController = TextEditingController();
  final _rateController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _onApply() {
    final rate = double.tryParse(_rateController.text);
    if (rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un tarif valide'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<JobBloc>().add(ApplyForJobEvent(
      jobId: widget.job.id!,
      coverLetter: _coverLetterController.text.trim().isEmpty
          ? null
          : _coverLetterController.text.trim(),
      proposedRate: rate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state.status == JobStateStatus.applied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidature envoyée !'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state.status == JobStateStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_showApplyForm)
            GradientButton(
              onPressed: () => setState(() => _showApplyForm = true),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text('Postuler'),
                ],
              ),
            )
          else
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Votre candidature',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _rateController,
                    label: 'Tarif proposé (${widget.job.currency})',
                    hint: 'ex: 500',
                    prefixIcon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _coverLetterController,
                    label: 'Message de motivation (optionnel)',
                    hint: 'Présentez votre expérience...',
                    prefixIcon: Icons.message_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showApplyForm = false),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: BlocBuilder<JobBloc, JobState>(
                          builder: (context, state) {
                            return GradientButton(
                              onPressed: state.isApplying ? null : _onApply,
                              isLoading: state.isApplying,
                              child: const Text('Envoyer'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
