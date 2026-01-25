import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with user's display name from registration
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      _displayNameController.text = authState.user!.displayName;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onCreateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(CreateProfileEvent(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isProvider = authState.user?.isProvider ?? false;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.created) {
          context.go('/home');
        } else if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Erreur'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a3e),
                AppColors.backgroundDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(context, isProvider),
                    const SizedBox(height: 32),
                    
                    // Profile form
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Créer votre profil',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isProvider
                                  ? 'Présentez vos compétences aux clients'
                                  : 'Complétez votre profil pour commencer',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Avatar placeholder
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surfaceLight,
                                      border: Border.all(
                                        color: isProvider 
                                            ? AppColors.providerColor 
                                            : AppColors.clientColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 48,
                                      color: isProvider 
                                          ? AppColors.providerColor 
                                          : AppColors.clientColor,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                        border: Border.all(
                                          color: AppColors.backgroundCard,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Display name
                            CustomTextField(
                              controller: _displayNameController,
                              label: 'Nom affiché',
                              hint: 'Votre nom professionnel',
                              prefixIcon: Icons.badge_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le nom est requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Bio
                            CustomTextField(
                              controller: _bioController,
                              label: 'Bio',
                              hint: isProvider
                                  ? 'Décrivez vos compétences et expériences...'
                                  : 'Présentez-vous brièvement...',
                              prefixIcon: Icons.info_outlined,
                              maxLines: 4,
                              minLines: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Location
                            CustomTextField(
                              controller: _locationController,
                              label: 'Localisation',
                              hint: 'Ville, Pays',
                              prefixIcon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 32),
                            
                            // Create button
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                return GradientButton(
                                  onPressed: state.isLoading ? null : _onCreateProfile,
                                  isLoading: state.isLoading,
                                  colors: isProvider
                                      ? [AppColors.providerColor, AppColors.secondary]
                                      : [AppColors.clientColor, AppColors.primary],
                                  child: const Text('Créer mon profil'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (isProvider ? AppColors.providerColor : AppColors.clientColor)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isProvider ? Icons.engineering : Icons.business_center,
                size: 18,
                color: isProvider ? AppColors.providerColor : AppColors.clientColor,
              ),
              const SizedBox(width: 8),
              Text(
                isProvider ? 'Prestataire' : 'Client',
                style: TextStyle(
                  color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bienvenue sur SkillMatch !',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
