import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../repository/job_repository.dart';
import 'job_event.dart';
import 'job_state.dart';

export 'job_event.dart';
export 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;

  JobBloc(this._jobRepository) : super(const JobState()) {
    on<LoadOpenJobsEvent>(_onLoadOpenJobs);
    on<LoadMyJobsEvent>(_onLoadMyJobs);
    on<LoadJobDetailEvent>(_onLoadJobDetail);
    on<CreateJobEvent>(_onCreateJob);
    on<ApplyForJobEvent>(_onApplyForJob);
    on<LoadMyApplicationsEvent>(_onLoadMyApplications);
    on<LoadJobApplicationsEvent>(_onLoadJobApplications);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SearchJobsEvent>(_onSearchJobs);
    on<UpdateJobEvent>(_onUpdateJob);
    on<DeleteJobEvent>(_onDeleteJob);
    on<ClearJobStateEvent>(_onClearState);
  }

  Future<void> _onUpdateJob(
    UpdateJobEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(isCreating: true)); // Reuse isCreating for loading
    try {
      final updatedJob = await _jobRepository.updateJob(
        event.jobId,
        title: event.title,
        description: event.description,
        budget: event.budget,
        currency: event.currency,
        location: event.location,
        deadline: event.deadline,
        requiredSkills: event.requiredSkills,
      );
      
      final updatedJobs = state.myJobs.map((j) => j.id == updatedJob.id ? updatedJob : j).toList();
      emit(state.copyWith(
        myJobs: updatedJobs,
        isCreating: false,
        status: JobStateStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la modification',
        isCreating: false,
      ));
    }
  }

  Future<void> _onDeleteJob(
    DeleteJobEvent event,
    Emitter<JobState> emit,
  ) async {
    try {
      await _jobRepository.deleteJob(event.jobId);
      final updatedJobs = state.myJobs.where((j) => j.id != event.jobId).toList();
      emit(state.copyWith(
        myJobs: updatedJobs,
        status: JobStateStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la suppression',
      ));
    }
  }

  Future<void> _onLoadOpenJobs(
    LoadOpenJobsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final jobs = await _jobRepository.getOpenJobs();
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        openJobs: jobs,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors du chargement des jobs',
      ));
    }
  }

  Future<void> _onLoadMyJobs(
    LoadMyJobsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final jobs = await _jobRepository.getMyJobs();
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        myJobs: jobs,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors du chargement de vos jobs',
      ));
    }
  }

  Future<void> _onLoadJobDetail(
    LoadJobDetailEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final job = await _jobRepository.getJob(event.jobId);
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        selectedJob: job,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors du chargement du job',
      ));
    }
  }

  Future<void> _onCreateJob(
    CreateJobEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(isCreating: true));
    
    try {
      final job = await _jobRepository.createJob(
        title: event.title,
        description: event.description,
        budget: event.budget,
        currency: event.currency,
        location: event.location,
        deadline: event.deadline,
        requiredSkills: event.requiredSkills,
        categoryId: event.categoryId,
      );
      
      final updatedJobs = [job, ...state.myJobs];
      emit(state.copyWith(
        status: JobStateStatus.created,
        myJobs: updatedJobs,
        isCreating: false,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
        isCreating: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la création du job',
        isCreating: false,
      ));
    }
  }

  Future<void> _onApplyForJob(
    ApplyForJobEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(isApplying: true));
    
    try {
      final application = await _jobRepository.applyForJob(
        jobId: event.jobId,
        coverLetter: event.coverLetter,
        proposedRate: event.proposedRate,
      );
      
      final updatedApplications = [application, ...state.myApplications];
      emit(state.copyWith(
        status: JobStateStatus.applied,
        myApplications: updatedApplications,
        isApplying: false,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
        isApplying: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la candidature',
        isApplying: false,
      ));
    }
  }

  Future<void> _onLoadMyApplications(
    LoadMyApplicationsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final applications = await _jobRepository.getMyApplications();
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        myApplications: applications,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors du chargement des candidatures',
      ));
    }
  }

  Future<void> _onLoadJobApplications(
    LoadJobApplicationsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final applications = await _jobRepository.getJobApplications(event.jobId);
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        jobApplications: applications,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors du chargement des candidatures',
      ));
    }
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatusEvent event,
    Emitter<JobState> emit,
  ) async {
    try {
      await _jobRepository.updateApplicationStatus(
        event.applicationId,
        event.status,
      );
      
      // Reload job applications using the event's jobId
      final applications = await _jobRepository.getJobApplications(event.jobId);
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        jobApplications: applications,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la mise à jour',
      ));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<JobState> emit,
  ) async {
    try {
      final categories = await _jobRepository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      // Silently fail for categories
    }
  }

  Future<void> _onSearchJobs(
    SearchJobsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(state.copyWith(status: JobStateStatus.loading));
    
    try {
      final jobs = await _jobRepository.searchJobs(event.query);
      emit(state.copyWith(
        status: JobStateStatus.loaded,
        openJobs: jobs,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JobStateStatus.error,
        errorMessage: 'Erreur lors de la recherche',
      ));
    }
  }

  Future<void> _onClearState(
    ClearJobStateEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(const JobState());
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? 'Erreur';
      }
      if (data is String) {
        return data;
      }
    }
    
    switch (e.response?.statusCode) {
      case 404:
        return 'Job non trouvé';
      case 403:
        return 'Accès non autorisé';
      case 400:
        return 'Données invalides';
      case 500:
        return 'Erreur serveur';
      default:
        return 'Erreur de connexion';
    }
  }
}
