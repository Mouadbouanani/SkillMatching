import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/jobs/repository/job_repository.dart';
import '../../features/jobs/bloc/job_bloc.dart';
import '../../features/messaging/repository/messaging_repository.dart';
import '../../features/messaging/bloc/messaging_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Dio instance
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  
  // Add interceptors
  dio.interceptors.add(AuthInterceptor(sharedPreferences));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  getIt.registerSingleton<Dio>(dio);
  
  // API Client
  getIt.registerSingleton<ApiClient>(ApiClient(dio));
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiClient>(), sharedPreferences),
  );
  
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ApiClient>()),
  );
  
  getIt.registerLazySingleton<JobRepository>(
    () => JobRepository(getIt<ApiClient>()),
  );
  
  getIt.registerLazySingleton<MessagingRepository>(
    () => MessagingRepository(getIt<ApiClient>()),
  );
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );
  
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getIt<ProfileRepository>()),
  );
  
  getIt.registerFactory<JobBloc>(
    () => JobBloc(getIt<JobRepository>()),
  );
  
  getIt.registerFactory<MessagingBloc>(
    () => MessagingBloc(getIt<MessagingRepository>()),
  );
}
