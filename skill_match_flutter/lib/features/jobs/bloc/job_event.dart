import 'package:equatable/equatable.dart';
import '../../../core/models/job_model.dart';
import '../../../core/models/job_application_model.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadOpenJobsEvent extends JobEvent {}

class LoadMyJobsEvent extends JobEvent {}

class LoadJobDetailEvent extends JobEvent {
  final String jobId;

  const LoadJobDetailEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class CreateJobEvent extends JobEvent {
  final String title;
  final String description;
  final double budget;
  final String currency;
  final String? location;
  final DateTime? deadline;
  final List<JobSkill>? requiredSkills;
  final String? categoryId;

  const CreateJobEvent({
    required this.title,
    required this.description,
    required this.budget,
    this.currency = 'MAD',
    this.location,
    this.deadline,
    this.requiredSkills,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    title, description, budget, currency, location, deadline, requiredSkills, categoryId
  ];
}

class ApplyForJobEvent extends JobEvent {
  final String jobId;
  final String? coverLetter;
  final double proposedRate;

  const ApplyForJobEvent({
    required this.jobId,
    this.coverLetter,
    required this.proposedRate,
  });

  @override
  List<Object?> get props => [jobId, coverLetter, proposedRate];
}

class LoadMyApplicationsEvent extends JobEvent {}

class LoadJobApplicationsEvent extends JobEvent {
  final String jobId;

  const LoadJobApplicationsEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class UpdateApplicationStatusEvent extends JobEvent {
  final String applicationId;
  final ApplicationStatus status;
  final String jobId;

  const UpdateApplicationStatusEvent({
    required this.applicationId,
    required this.status,
    required this.jobId,
  });

  @override
  List<Object?> get props => [applicationId, status, jobId];
}

class LoadCategoriesEvent extends JobEvent {}

class SearchJobsEvent extends JobEvent {
  final String query;

  const SearchJobsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateJobEvent extends JobEvent {
  final String jobId;
  final String title;
  final String description;
  final double budget;
  final String currency;
  final String? location;
  final DateTime? deadline;
  final List<JobSkill>? requiredSkills;

  const UpdateJobEvent({
    required this.jobId,
    required this.title,
    required this.description,
    required this.budget,
    this.currency = 'MAD',
    this.location,
    this.deadline,
    this.requiredSkills,
  });

  @override
  List<Object?> get props => [
    jobId, title, description, budget, currency, location, deadline, requiredSkills
  ];
}

class DeleteJobEvent extends JobEvent {
  final String jobId;

  const DeleteJobEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class ClearJobStateEvent extends JobEvent {}
