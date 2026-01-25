import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/skill_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skillNameController = TextEditingController();
  final _yearsController = TextEditingController();
  int _proficiencyLevel = 3;

  @override
  void dispose() {
    _skillNameController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _onAddSkill() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) return;

      final skill = Skill(
        skillName: _skillNameController.text.trim(),
        proficiencyLevel: _proficiencyLevel,
        yearsExperience: int.tryParse(_yearsController.text),
      );

      context.read<ProfileBloc>().add(AddSkillEvent(
        userId: authState.user!.firebaseUid ?? authState.user!.id,
        skill: skill,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.updated && !state.isAddingSkill) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compétence ajoutée !'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage?.contains('Redis') == true
                          ? 'Service temporairement indisponible (Erreur serveur)'
                          : state.errorMessage ?? 'Une erreur est survenue',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter une compétence'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(
                    Icons.psychology,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nouvelle compétence',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez une compétence à votre profil',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Skill name
                  CustomTextField(
                    controller: _skillNameController,
                    label: 'Nom de la compétence',
                    hint: 'ex: Flutter, Java, Design...',
                    prefixIcon: Icons.code,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Proficiency level
                  Text(
                    'Niveau de maîtrise',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProficiencySelector(),
                  const SizedBox(height: 24),

                  // Years of experience
                  CustomTextField(
                    controller: _yearsController,
                    label: 'Années d\'expérience (optionnel)',
                    hint: 'ex: 3',
                    prefixIcon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return GradientButton(
                        onPressed: state.isAddingSkill ? null : _onAddSkill,
                        isLoading: state.isAddingSkill,
                        child: const Text('Ajouter'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProficiencySelector() {
    final levels = [
      {'value': 1, 'label': 'Débutant', 'icon': Icons.school_outlined},
      {'value': 2, 'label': 'Junior', 'icon': Icons.trending_up},
      {'value': 3, 'label': 'Intermédiaire', 'icon': Icons.equalizer},
      {'value': 4, 'label': 'Senior', 'icon': Icons.star_outline},
      {'value': 5, 'label': 'Expert', 'icon': Icons.workspace_premium},
    ];

    return Column(
      children: [
        Row(
          children: levels.map((level) {
            final isSelected = _proficiencyLevel == level['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _proficiencyLevel = level['value'] as int;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        level['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (level['value'] as int).toString(),
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                levels[_proficiencyLevel - 1]['icon'] as IconData,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                levels[_proficiencyLevel - 1]['label'] as String,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
