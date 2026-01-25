import '../../../core/network/api_client.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/job_application_model.dart';

class JobRepository {
  final ApiClient _apiClient;

  JobRepository(this._apiClient);

  Future<Job> createJob({
    required String title,
    required String description,
    required double budget,
    String currency = 'MAD',
    String? location,
    DateTime? deadline,
    List<JobSkill>? requiredSkills,
    String? categoryId,
  }) async {
    final response = await _apiClient.createJob(
      title: title,
      description: description,
      budget: budget,
      currency: currency,
      location: location,
      deadline: deadline,
      requiredSkills: requiredSkills?.map((s) => s.toJson()).toList(),
      categoryId: categoryId,
    );
    return Job.fromJson(response.data);
  }

  Future<List<Job>> getOpenJobs() async {
    final response = await _apiClient.getOpenJobs();
    final List<dynamic> data = response.data;
    return data.map((j) => Job.fromJson(j)).toList();
  }

  Future<List<Job>> getMyJobs() async {
    final response = await _apiClient.getMyJobs();
    final List<dynamic> data = response.data;
    return data.map((j) => Job.fromJson(j)).toList();
  }

  Future<Job> getJob(String jobId) async {
    final response = await _apiClient.getJob(jobId);
    return Job.fromJson(response.data);
  }

  Future<JobApplication> applyForJob({
    required String jobId,
    String? coverLetter,
    required double proposedRate,
  }) async {
    final response = await _apiClient.applyForJob(
      jobId: jobId,
      coverLetter: coverLetter,
      proposedRate: proposedRate,
    );
    return JobApplication.fromJson(response.data);
  }

  Future<List<JobApplication>> getMyApplications() async {
    final response = await _apiClient.getMyApplications();
    final List<dynamic> data = response.data;
    return data.map((a) => JobApplication.fromJson(a)).toList();
  }

  Future<List<JobApplication>> getJobApplications(String jobId) async {
    final response = await _apiClient.getJobApplications(jobId);
    final List<dynamic> data = response.data;
    return data.map((a) => JobApplication.fromJson(a)).toList();
  }

  Future<JobApplication> updateApplicationStatus(
    String applicationId, 
    ApplicationStatus status,
  ) async {
    final response = await _apiClient.updateApplicationStatus(
      applicationId,
      status.name.toUpperCase(),
    );
    return JobApplication.fromJson(response.data);
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.getCategories();
    final List<dynamic> data = response.data;
    return data.map((c) => Category.fromJson(c)).toList();
  }

  Future<List<Job>> searchJobs(String query) async {
    final response = await _apiClient.searchJobs(query);
    final List<dynamic> data = response.data;
    return data.map((j) => Job.fromJson(j)).toList();
  }

  Future<Job> updateJobStatus(String jobId, JobStatus status) async {
    final response = await _apiClient.updateJobStatus(
      jobId,
      status.name.toUpperCase(),
    );
    return Job.fromJson(response.data);
  }
  Future<Job> updateJob(String jobId, {
    String? title,
    String? description,
    double? budget,
    String? currency,
    String? location,
    DateTime? deadline,
    List<JobSkill>? requiredSkills,
    String? categoryId,
  }) async {
    final response = await _apiClient.updateJob(
      jobId,
      title: title,
      description: description,
      budget: budget,
      currency: currency,
      location: location,
      deadline: deadline,
      requiredSkills: requiredSkills?.map((s) => s.toJson()).toList(),
      categoryId: categoryId,
    );
    return Job.fromJson(response.data);
  }

  Future<void> deleteJob(String jobId) async {
    await _apiClient.deleteJob(jobId);
  }
}
