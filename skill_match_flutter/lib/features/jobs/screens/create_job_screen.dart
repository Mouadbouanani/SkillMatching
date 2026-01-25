import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/job_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../bloc/job_bloc.dart';

class CreateJobScreen extends StatefulWidget {
  final Job? initialJob;
  const CreateJobScreen({super.key, this.initialJob});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _budgetController;
  late final TextEditingController _locationController;
  final _skillController = TextEditingController();

  String _currency = 'MAD';
  DateTime? _deadline;
  final List<String> _skills = [];

  bool get isEditMode => widget.initialJob != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialJob?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialJob?.description ?? '');
    _budgetController = TextEditingController(text: widget.initialJob?.budget.toString() ?? '');
    _locationController = TextEditingController(text: widget.initialJob?.location ?? '');
    
    if (isEditMode) {
      _currency = widget.initialJob!.currency;
      _deadline = widget.initialJob!.deadline;
      _skills.addAll(widget.initialJob!.requiredSkills.map((s) => s.skillName));
    }
    
    context.read<JobBloc>().add(LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.backgroundCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _deadline = date;
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final budget = double.tryParse(_budgetController.text);
      if (budget == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget invalide'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (isEditMode) {
        context.read<JobBloc>().add(UpdateJobEvent(
          jobId: widget.initialJob!.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          budget: budget,
          currency: _currency,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          deadline: _deadline,
          requiredSkills: _skills.map((s) => JobSkill(skillName: s)).toList(),
        ));
      } else {
        context.read<JobBloc>().add(CreateJobEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          budget: budget,
          currency: _currency,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          deadline: _deadline,
          requiredSkills: _skills.map((s) => JobSkill(skillName: s)).toList(),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state.status == JobStateStatus.created || (!state.isCreating && isEditMode && state.status == JobStateStatus.loaded)) {
          final message = isEditMode ? 'Job mis à jour !' : 'Job créé avec succès !';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Modifier le job' : 'Créer un job'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Icon(
                        isEditMode ? Icons.edit_note : Icons.work_outline,
                        size: 48,
                        color: AppColors.clientColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEditMode ? 'Modifier le job' : 'Nouveau job',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Title
                      CustomTextField(
                        controller: _titleController,
                        label: 'Titre du job',
                        hint: 'ex: Développement d\'une application mobile',
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le titre est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Décrivez les détails du travail...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 5,
                        minLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La description est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Budget row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _budgetController,
                              label: 'Budget',
                              hint: 'ex: 5000',
                              prefixIcon: Icons.monetization_on_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Devise',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _currency,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: AppColors.backgroundElevated,
                                    items: const [
                                      DropdownMenuItem(value: 'MAD', child: Text('MAD')),
                                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _currency = value);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location
                      CustomTextField(
                        controller: _locationController,
                        label: 'Lieu (optionnel)',
                        hint: 'ex: Casablanca, Maroc',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date limite (optionnel)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDeadline,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _deadline != null
                                        ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                        : 'Sélectionner une date',
                                    style: TextStyle(
                                      color: _deadline != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_deadline != null)
                                    GestureDetector(
                                      onTap: () => setState(() => _deadline = null),
                                      child: const Icon(
                                        Icons.close,
                                        color: AppColors.textMuted,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Skills
                      Text(
                        'Compétences requises',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skillController,
                              decoration: const InputDecoration(
                                hintText: 'ex: Flutter',
                                prefixIcon: Icon(Icons.code, size: 20),
                              ),
                              onSubmitted: (_) => _addSkill(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addSkill,
                            icon: const Icon(Icons.add_circle),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      if (_skills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    skill,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _removeSkill(skill),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit button
                BlocBuilder<JobBloc, JobState>(
                  builder: (context, state) {
                    return GradientButton(
                      onPressed: state.isCreating ? null : _onSave,
                      isLoading: state.isCreating,
                      colors: [AppColors.clientColor, AppColors.primary],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isEditMode ? Icons.save : Icons.publish, size: 20),
                          const SizedBox(width: 8),
                          Text(isEditMode ? 'Enregistrer les modifications' : 'Publier le job'),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
