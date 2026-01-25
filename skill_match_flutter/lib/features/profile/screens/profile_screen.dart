import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    final userId = widget.userId ?? authState.user?.firebaseUid ?? authState.user?.id;
    if (userId != null) {
      context.read<ProfileBloc>().add(LoadProfileEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isOwnProfile = widget.userId == null || widget.userId == authState.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Mon profil' : 'Profil'),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingIndicator();
          }

          if (state.status == ProfileStatus.error) {
            return ErrorState(
              message: state.errorMessage ?? 'Erreur',
              onRetry: _loadProfile,
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              title: isOwnProfile ? 'Profil non trouvé' : 'Profil incomplet',
              subtitle: isOwnProfile 
                  ? 'Vous n\'avez pas encore créé votre profil.'
                  : 'Cet utilisateur n\'a pas encore renseigné ses informations.',
              action: isOwnProfile
                  ? GradientButton(
                      onPressed: () => context.go('/create-profile'),
                      child: const Text('Créer mon profil'),
                    )
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile header
                      _buildProfileHeader(context, profile, authState.user?.isProvider ?? false, isOwnProfile),
                      const SizedBox(height: 24),

                      // Stats
                      _buildStats(context, profile),
                      const SizedBox(height: 24),

                      // Bio section
                      _buildSection(
                        context,
                        title: 'À propos',
                        icon: Icons.info_outline,
                        child: Text(
                          (profile.bio != null && profile.bio!.isNotEmpty) 
                              ? profile.bio! 
                              : 'Aucune description fournie.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: (profile.bio == null || profile.bio!.isEmpty) 
                                ? FontStyle.italic 
                                : FontStyle.normal,
                            color: (profile.bio == null || profile.bio!.isEmpty)
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location & Availability
                      if (profile.location != null || profile.availability != null) ...[
                        _buildSection(
                          context,
                          title: 'Informations',
                          icon: Icons.assignment_ind_outlined,
                          child: Column(
                            children: [
                              if (profile.location != null)
                                _InfoRow(icon: Icons.location_on, label: 'Localisation', value: profile.location!),
                              if (profile.location != null && profile.availability != null)
                                const SizedBox(height: 12),
                              if (profile.availability != null)
                                _InfoRow(icon: Icons.schedule, label: 'Disponibilité', value: profile.availability!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Skills section (for providers)
                      if (authState.user?.isProvider ?? false) ...[
                        _buildSkillsSection(context, state, isOwnProfile),
                        const SizedBox(height: 32),
                      ],

                      // Logout Button (visible only for own profile)
                      if (isOwnProfile)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: GradientButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(LogoutEvent());
                              context.go('/login');
                            },
                            colors: [AppColors.error.withOpacity(0.8), AppColors.error],
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Se déconnecter'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, profile, bool isProvider, bool isOwnProfile) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Modifier le profil',
                  onPressed: () {
                    context.pushNamed('edit-profile', extra: profile).then((_) {
                      // Reload profile after returning from edit
                      final authState = context.read<AuthBloc>().state;
                      if (authState.user != null) {
                        context.read<ProfileBloc>().add(LoadProfileEvent(authState.user!.id));
                      }
                    });
                  },
                ),
            ],
          ),
          
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
              border: Border.all(
                color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                width: 4,
              ),
              image: profile.profilePictureUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profile.profilePictureUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.profilePictureUrl == null
                ? Icon(
                    Icons.person,
                    size: 64,
                    color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                  )
                : null,
          ),
          const SizedBox(height: 24),

          // Name
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: (isProvider ? AppColors.providerColor : AppColors.clientColor)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isProvider ? 'PRESTATAIRE' : 'CLIENT',
              style: TextStyle(
                color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, profile) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            value: profile.rating.toStringAsFixed(1),
            label: 'Note',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.reviews_outlined,
            value: profile.ratingCount.toString(),
            label: 'Avis',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.code,
            value: profile.skills.length.toString(),
            label: 'Skills',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, ProfileState state, bool isOwnProfile) {
    final skills = state.profile?.skills ?? [];

    return _buildSection(
      context,
      title: 'Compétences',
      icon: Icons.psychology_outlined,
      action: isOwnProfile
          ? IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
              onPressed: () => context.push('/add-skill'),
            )
          : null,
      child: skills.isEmpty
          ? Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.code_off,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune compétence ajoutée',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (isOwnProfile) ...[
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () => context.push('/add-skill'),
                      height: 44,
                      child: const Text('Ajouter une compétence'),
                    ),
                  ],
                ],
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill.proficiencyLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
