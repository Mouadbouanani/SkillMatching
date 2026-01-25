import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/job_model.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/profile/screens/create_profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/add_skill_screen.dart';
import '../../features/jobs/screens/jobs_list_screen.dart';
import '../../features/jobs/screens/job_detail_screen.dart';
import '../../features/jobs/screens/create_job_screen.dart';
import '../../features/jobs/screens/my_jobs_screen.dart';
import '../../features/jobs/screens/job_applications_screen.dart';
import '../../features/jobs/screens/my_applications_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/messaging/screens/chat_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Profile creation (after registration)
      GoRoute(
        path: '/create-profile',
        name: 'create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      
      // Main home with bottom navigation
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Jobs routes
      GoRoute(
        path: '/jobs',
        name: 'jobs',
        builder: (context, state) => const JobsListScreen(),
      ),
      GoRoute(
        path: '/jobs/:jobId',
        name: 'job-detail',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/create-job',
        name: 'create-job',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/edit-job/:jobId',
        name: 'edit-job',
        builder: (context, state) {
          final job = state.extra as Job?;
          return CreateJobScreen(initialJob: job);
        },
      ),
      GoRoute(
        path: '/my-jobs',
        name: 'my-jobs',
        builder: (context, state) => const MyJobsScreen(),
      ),
      GoRoute(
        path: '/jobs/:jobId/applications',
        name: 'job-applications',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobApplicationsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/my-applications',
        name: 'my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      
      // Profile routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        name: 'profile-view',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) {
          final profile = state.extra as dynamic;
          return EditProfileScreen(profile: profile); 
        },
      ),
      GoRoute(
        path: '/add-skill',
        name: 'add-skill',
        builder: (context, state) => const AddSkillScreen(),
      ),

      // Messaging routes
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            conversationId: state.pathParameters['conversationId']!,
            otherUserId: extra?['otherUserId'] ?? '',
            otherUserName: extra?['otherUserName'] ?? 'Chat',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
