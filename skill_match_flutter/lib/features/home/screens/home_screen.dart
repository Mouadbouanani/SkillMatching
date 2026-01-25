import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../jobs/bloc/job_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../messaging/screens/conversations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<ProfileBloc>().add(LoadProfileEvent(authState.user!.id));
      
      if (authState.user!.isClient) {
        context.read<JobBloc>().add(LoadMyJobsEvent());
      } else {
        context.read<JobBloc>().add(LoadOpenJobsEvent());
        context.read<JobBloc>().add(LoadMyApplicationsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isClient = authState.user?.isClient ?? false;
    final isProvider = authState.user?.isProvider ?? false;

    final screens = isClient
        ? [
            _ClientDashboard(),
            _JobsTab(isClient: true),
            ConversationsScreen(),
            _ProfileTab(),
          ]
        : [
            _ProviderDashboard(),
            _JobsTab(isClient: false),
            ConversationsScreen(),
            _ProfileTab(),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(isClient ? Icons.work_outline : Icons.search),
              activeIcon: Icon(isClient ? Icons.work : Icons.search),
              label: isClient ? 'Mes Jobs' : 'Jobs',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications bientôt disponibles')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<JobBloc>().add(LoadMyJobsEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              _buildWelcomeCard(context),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Créer un job',
                      color: AppColors.clientColor,
                      onTap: () => context.push('/create-job'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.list_alt,
                      title: 'Mes jobs',
                      color: AppColors.primary,
                      onTap: () => context.push('/my-jobs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats
              _buildStats(context),
              const SizedBox(height: 24),

              // Recent jobs
              _buildRecentJobs(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.clientColor, AppColors.primary],
              ),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${authState.user?.displayName ?? 'Client'}! 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trouvez les meilleurs talents pour vos projets',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        final totalJobs = state.myJobs.length;
        final openJobs = state.myJobs.where((j) => j.status.name == 'open').length;
        final inProgress = state.myJobs.where((j) => j.status.name == 'inProgress').length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.work,
                value: totalJobs.toString(),
                label: 'Total Jobs',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.published_with_changes,
                value: openJobs.toString(),
                label: 'Ouverts',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.hourglass_bottom,
                value: inProgress.toString(),
                label: 'Attribués',
                color: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentJobs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jobs récents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/my-jobs'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<JobBloc, JobState>(
          builder: (context, state) {
            if (state.myJobs.isEmpty) {
              return GlassCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.work_off_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun job créé',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      onPressed: () => context.push('/create-job'),
                      colors: [AppColors.clientColor, AppColors.primary],
                      child: const Text('Créer mon premier job'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: state.myJobs.take(3).map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentJobCard(
                    title: job.title,
                    budget: job.formattedBudget,
                    status: job.statusLabel,
                    onTap: () => context.push('/jobs/${job.id}'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ProviderDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications bientôt disponibles')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<JobBloc>().add(LoadOpenJobsEvent());
          context.read<JobBloc>().add(LoadMyApplicationsEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              _buildWelcomeCard(context),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.search,
                      title: 'Trouver un job',
                      color: AppColors.providerColor,
                      onTap: () => context.push('/jobs'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.send,
                      title: 'Mes candidatures',
                      color: AppColors.primary,
                      onTap: () => context.push('/my-applications'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats
              _buildStats(context),
              const SizedBox(height: 24),

              // Available jobs
              _buildAvailableJobs(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.providerColor, AppColors.secondary],
              ),
            ),
            child: const Icon(
              Icons.engineering,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${authState.user?.displayName ?? 'Provider'}! 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Découvrez les opportunités qui vous correspondent',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        final openJobs = state.openJobs.length;
        final myApplications = state.myApplications.length;
        final accepted = state.myApplications.where(
          (a) => a.status.name == 'accepted'
        ).length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.work_outline,
                value: openJobs.toString(),
                label: 'Jobs dispo',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.send,
                value: myApplications.toString(),
                label: 'Candidatures',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                value: accepted.toString(),
                label: 'Acceptées',
                color: AppColors.providerColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvailableJobs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jobs disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/jobs'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<JobBloc, JobState>(
          builder: (context, state) {
            if (state.openJobs.isEmpty) {
              return GlassCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun job disponible',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revenez plus tard',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: state.openJobs.take(3).map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentJobCard(
                    title: job.title,
                    budget: job.formattedBudget,
                    status: job.statusLabel,
                    onTap: () => context.push('/jobs/${job.id}'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _JobsTab extends StatelessWidget {
  final bool isClient;

  const _JobsTab({required this.isClient});

  @override
  Widget build(BuildContext context) {
    if (isClient) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Jobs')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/create-job'),
          icon: const Icon(Icons.add),
          label: const Text('Créer'),
          backgroundColor: AppColors.clientColor,
        ),
        body: _buildClientJobs(context),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Jobs disponibles')),
        body: _buildProviderJobs(context),
      );
    }
  }

  Widget _buildClientJobs(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state.myJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_outline, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('Aucun job créé', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                GradientButton(
                  onPressed: () => context.push('/create-job'),
                  child: const Text('Créer un job'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.myJobs.length,
          itemBuilder: (context, index) {
            final job = state.myJobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecentJobCard(
                title: job.title,
                budget: job.formattedBudget,
                status: job.statusLabel,
                onTap: () => context.push('/jobs/${job.id}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProviderJobs(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state.openJobs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                SizedBox(height: 16),
                Text('Aucun job disponible'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.openJobs.length,
          itemBuilder: (context, index) {
            final job = state.openJobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecentJobCard(
                title: job.title,
                budget: job.formattedBudget,
                status: job.statusLabel,
                onTap: () => context.push('/jobs/${job.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    // Just navigate to profile screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load profile if not loaded
      final authState = context.read<AuthBloc>().state;
      final profileState = context.read<ProfileBloc>().state;
      if (authState.user != null && profileState.profile == null) {
        context.read<ProfileBloc>().add(LoadProfileEvent(authState.user!.id));
      }
    });

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final authState = context.watch<AuthBloc>().state;
        final isProvider = authState.user?.isProvider ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.go('/login');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile card
                GlassCard(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceLight,
                          border: Border.all(
                            color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.profile?.displayName ?? authState.user?.displayName ?? 'Utilisateur',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isProvider ? AppColors.providerColor : AppColors.clientColor)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isProvider ? 'Prestataire' : 'Client',
                          style: TextStyle(
                            color: isProvider ? AppColors.providerColor : AppColors.clientColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (state.profile?.location != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              state.profile!.location!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Skills section for providers
                if (isProvider) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Mes compétences',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.primary,
                              onPressed: () => context.push('/add-skill'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state.profile?.skills.isEmpty ?? true)
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.code_off, size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                const Text('Aucune compétence'),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => context.push('/add-skill'),
                                  child: const Text('Ajouter'),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.profile!.skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
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
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
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
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentJobCard extends StatelessWidget {
  final String title;
  final String budget;
  final String status;
  final VoidCallback onTap;

  const _RecentJobCard({
    required this.title,
    required this.budget,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        budget,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
