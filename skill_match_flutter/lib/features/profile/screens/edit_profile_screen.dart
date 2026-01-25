import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/profile_model.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../bloc/profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _availabilityController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _locationController = TextEditingController(text: widget.profile.location);
    _availabilityController = TextEditingController(text: widget.profile.availability);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedData = {
        'displayName': _displayNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'availability': _availabilityController.text.trim(),
      };

      context.read<ProfileBloc>().add(UpdateProfileEvent(
        userId: widget.profile.userId,
        data: updatedData,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Erreur lors de la mise à jour'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le profil'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar (Read-only for now)
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
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                image: widget.profile.profilePictureUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(widget.profile.profilePictureUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: widget.profile.profilePictureUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
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
                      const SizedBox(height: 32),

                      // Display Name
                      CustomTextField(
                        controller: _displayNameController,
                        label: 'Nom affiché',
                        prefixIcon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nom est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location
                      CustomTextField(
                        controller: _locationController,
                        label: 'Localisation',
                        prefixIcon: Icons.location_on_outlined,
                        hint: 'Ville, Pays',
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      CustomTextField(
                        controller: _bioController,
                        label: 'À propos',
                        prefixIcon: Icons.info_outline,
                        hint: 'Décrivez-vous...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // Availability
                      CustomTextField(
                        controller: _availabilityController,
                        label: 'Disponibilité',
                        prefixIcon: Icons.schedule_outlined,
                        hint: 'Ex: Disponible à temps plein, soirs et weekends...',
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          return GradientButton(
                            onPressed: state.isLoading ? null : _onSave,
                            isLoading: state.isLoading,
                            child: const Text('Enregistrer les modifications'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
