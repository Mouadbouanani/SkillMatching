/// Configuration API pour les endpoints backend
class ApiConfig {
  // Base URL - À configurer selon l'environnement
  static const String baseUrl = 'http://localhost:8080';
  
  // Service endpoints via API Gateway
  static const String usersEndpoint = '/api/users';
  static const String profilesEndpoint = '/api/profiles';
  static const String jobsEndpoint = '/api/jobs';
  static const String matchesEndpoint = '/api/matches';
  static const String notificationsEndpoint = '/api/notifications';
  static const String messagesEndpoint = '/api/messages';
  
  // Auth endpoints
  static const String registerEndpoint = '$usersEndpoint/register';
  static const String loginEndpoint = '$usersEndpoint/login';
  static const String meEndpoint = '$usersEndpoint/me';
  
  // Profile endpoints
  static const String createProfileEndpoint = '$profilesEndpoint/create';
  static String getProfileEndpoint(String userId) => '$profilesEndpoint/$userId';
  static String updateProfileEndpoint(String userId) => '$profilesEndpoint/$userId';
  static String addSkillEndpoint(String userId) => '$profilesEndpoint/$userId/skills';
  
  // Job endpoints
  static const String createJobEndpoint = '$jobsEndpoint/create';
  static const String openJobsEndpoint = '$jobsEndpoint/open';
  static const String myJobsEndpoint = '$jobsEndpoint/my';
  static const String applyJobEndpoint = '$jobsEndpoint/apply';
  static const String myApplicationsEndpoint = '$jobsEndpoint/applications/my';
  static String jobApplicationsEndpoint(String jobId) => '$jobsEndpoint/$jobId/applications';
  static String updateApplicationStatusEndpoint(String applicationId) => 
      '$jobsEndpoint/applications/$applicationId/status';
  static const String categoriesEndpoint = '$jobsEndpoint/categories';
  
  // Match endpoints
  static String suggestionsEndpoint(String jobId) => '$matchesEndpoint/suggestions/$jobId';

  static String acceptMatchEndpoint(String matchId) => '$matchesEndpoint/$matchId/accept';
  
  // Messaging endpoints
  static const String sendMessagePath = '$messagesEndpoint/send';
  static const String conversationsPath = '$messagesEndpoint/conversations';
  static String conversationMessagesPath(String conversationId) => '$messagesEndpoint/conversation/$conversationId';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
