import 'package:equatable/equatable.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/job_application_model.dart';

enum JobStateStatus { initial, loading, loaded, error, created, applied }

class JobState extends Equatable {
  final JobStateStatus status;
  final List<Job> openJobs;
  final List<Job> myJobs;
  final Job? selectedJob;
  final List<JobApplication> myApplications;
  final List<JobApplication> jobApplications;
  final List<Category> categories;
  final String? errorMessage;
  final bool isApplying;
  final bool isCreating;

  const JobState({
    this.status = JobStateStatus.initial,
    this.openJobs = const [],
    this.myJobs = const [],
    this.selectedJob,
    this.myApplications = const [],
    this.jobApplications = const [],
    this.categories = const [],
    this.errorMessage,
    this.isApplying = false,
    this.isCreating = false,
  });

  JobState copyWith({
    JobStateStatus? status,
    List<Job>? openJobs,
    List<Job>? myJobs,
    Job? selectedJob,
    List<JobApplication>? myApplications,
    List<JobApplication>? jobApplications,
    List<Category>? categories,
    String? errorMessage,
    bool? isApplying,
    bool? isCreating,
  }) {
    return JobState(
      status: status ?? this.status,
      openJobs: openJobs ?? this.openJobs,
      myJobs: myJobs ?? this.myJobs,
      selectedJob: selectedJob ?? this.selectedJob,
      myApplications: myApplications ?? this.myApplications,
      jobApplications: jobApplications ?? this.jobApplications,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      isApplying: isApplying ?? this.isApplying,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  bool get isLoading => status == JobStateStatus.loading;

  @override
  List<Object?> get props => [
    status, openJobs, myJobs, selectedJob, myApplications, 
    jobApplications, categories, errorMessage, isApplying, isCreating
  ];
}
