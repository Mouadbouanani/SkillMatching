import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio);
  
  // Auth endpoints
  Future<Response> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phoneNumber,
  }) async {
    return await _dio.post(
      ApiConfig.registerEndpoint,
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      },
    );
  }
  
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      ApiConfig.loginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );
  }
  
  Future<Response> getCurrentUser() async {
    return await _dio.get(ApiConfig.meEndpoint);
  }
  
  // Profile endpoints
  Future<Response> createProfile({
    required String displayName,
    String? bio,
    String? location,
    String? availability,
    String? profilePictureUrl,
  }) async {
    return await _dio.post(
      ApiConfig.createProfileEndpoint,
      data: {
        'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (availability != null) 'availability': availability,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      },
    );
  }
  
  Future<Response> getProfile(String userId) async {
    return await _dio.get(ApiConfig.getProfileEndpoint(userId));
  }
  
  Future<Response> updateProfile(String userId, Map<String, dynamic> data) async {
    return await _dio.put(ApiConfig.updateProfileEndpoint(userId), data: data);
  }
  
  Future<Response> addSkill(String userId, {
    required String skillName,
    required int proficiencyLevel,
    int? yearsExperience,
  }) async {
    return await _dio.post(
      ApiConfig.addSkillEndpoint(userId),
      data: {
        'skillName': skillName,
        'proficiencyLevel': proficiencyLevel,
        if (yearsExperience != null) 'yearsExperience': yearsExperience,
      },
    );
  }
  
  // Job endpoints
  Future<Response> createJob({
    required String title,
    required String description,
    required double budget,
    String currency = 'MAD',
    String? location,
    DateTime? deadline,
    List<Map<String, dynamic>>? requiredSkills,
    String? categoryId,
  }) async {
    return await _dio.post(
      ApiConfig.createJobEndpoint,
      data: {
        'title': title,
        'description': description,
        'budget': budget,
        'currency': currency,
        if (location != null) 'location': location,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (requiredSkills != null) 'requiredSkills': requiredSkills,
        if (categoryId != null) 'category': {'id': categoryId},
      },
    );
  }

  Future<Response> updateJob(String jobId, {
    String? title,
    String? description,
    double? budget,
    String? currency,
    String? location,
    DateTime? deadline,
    List<Map<String, dynamic>>? requiredSkills,
    String? categoryId,
  }) async {
    return await _dio.put(
      '${ApiConfig.jobsEndpoint}/$jobId',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (budget != null) 'budget': budget,
        if (currency != null) 'currency': currency,
        if (location != null) 'location': location,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (requiredSkills != null) 'requiredSkills': requiredSkills,
        if (categoryId != null) 'category': {'id': categoryId},
      },
    );
  }

  Future<Response> deleteJob(String jobId) async {
    return await _dio.delete('${ApiConfig.jobsEndpoint}/$jobId');
  }
  
  Future<Response> getOpenJobs() async {
    return await _dio.get(ApiConfig.openJobsEndpoint);
  }
  
  Future<Response> getMyJobs() async {
    return await _dio.get(ApiConfig.myJobsEndpoint);
  }
  
  Future<Response> getJob(String jobId) async {
    return await _dio.get('${ApiConfig.jobsEndpoint}/$jobId');
  }
  
  Future<Response> applyForJob({
    required String jobId,
    String? coverLetter,
    required double proposedRate,
  }) async {
    return await _dio.post(
      ApiConfig.applyJobEndpoint,
      data: {
        'jobId': jobId,
        if (coverLetter != null) 'coverLetter': coverLetter,
        'proposedRate': proposedRate,
      },
    );
  }
  
  Future<Response> getMyApplications() async {
    return await _dio.get(ApiConfig.myApplicationsEndpoint);
  }
  
  Future<Response> getJobApplications(String jobId) async {
    return await _dio.get(ApiConfig.jobApplicationsEndpoint(jobId));
  }
  
  Future<Response> updateApplicationStatus(String applicationId, String status) async {
    return await _dio.put(
      ApiConfig.updateApplicationStatusEndpoint(applicationId),
      queryParameters: {'status': status},
    );
  }
  
  Future<Response> getCategories() async {
    return await _dio.get(ApiConfig.categoriesEndpoint);
  }
  
  Future<Response> searchJobs(String query) async {
    return await _dio.get(
      '${ApiConfig.jobsEndpoint}/search',
      queryParameters: {'q': query},
    );
  }
  
  Future<Response> updateJobStatus(String jobId, String status) async {
    return await _dio.put(
      '${ApiConfig.jobsEndpoint}/$jobId/status',
      queryParameters: {'status': status},
    );
  }
  
  // Match endpoints
  Future<Response> getMatchSuggestions(String jobId) async {
    return await _dio.get(ApiConfig.suggestionsEndpoint(jobId));
  }
  
  Future<Response> acceptMatch(String matchId) async {
    return await _dio.post(ApiConfig.acceptMatchEndpoint(matchId));
  }

  // Messaging endpoints
  Future<Response> getUserConversations(String userId) async {
    return await _dio.get(
      ApiConfig.conversationsPath,
      queryParameters: {'userId': userId},
    );
  }

  Future<Response> getConversationMessages(String conversationId) async {
    return await _dio.get(ApiConfig.conversationMessagesPath(conversationId));
  }

  Future<Response> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String type = 'TEXT',
  }) async {
    return await _dio.post(
      ApiConfig.sendMessagePath,
      data: {
        'conversationId': conversationId,
        'fromId': senderId,
        'text': content,
        'type': type,
      },
    );
  }

  Future<Response> createConversation({
    required String matchId,
    required String participant1Id,
    required String participant2Id,
  }) async {
    return await _dio.post(
      ApiConfig.conversationsPath,
      data: {
        'matchId': matchId,
        'participant1Id': participant1Id,
        'participant2Id': participant2Id,
      },
    );
  }
}
