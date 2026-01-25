import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, reviewed, accepted, rejected, cancelled }

class JobApplication extends Equatable {
  final String? id;
  final String jobId;
  final String providerId;
  final String? coverLetter;
  final double proposedRate;
  final ApplicationStatus status;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  const JobApplication({
    this.id,
    required this.jobId,
    required this.providerId,
    this.coverLetter,
    required this.proposedRate,
    this.status = ApplicationStatus.pending,
    this.appliedAt,
    this.updatedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['jobId'] ?? '',
      providerId: json['providerId'] ?? '',
      coverLetter: json['coverLetter'],
      proposedRate: (json['proposedRate'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      appliedAt: json['appliedAt'] != null 
          ? DateTime.tryParse(json['appliedAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'jobId': jobId,
      'providerId': providerId,
      if (coverLetter != null) 'coverLetter': coverLetter,
      'proposedRate': proposedRate,
      'status': status.name.toUpperCase(),
    };
  }

  static ApplicationStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return ApplicationStatus.pending;
      case 'REVIEWED':
        return ApplicationStatus.reviewed;
      case 'ACCEPTED':
        return ApplicationStatus.accepted;
      case 'REJECTED':
        return ApplicationStatus.rejected;
      case 'CANCELLED':
        return ApplicationStatus.cancelled;
      default:
        return ApplicationStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.reviewed:
        return 'Examiné';
      case ApplicationStatus.accepted:
        return 'Accepté';
      case ApplicationStatus.rejected:
        return 'Refusé';
      case ApplicationStatus.cancelled:
        return 'Annulé';
    }
  }

  @override
  List<Object?> get props => [
    id, jobId, providerId, coverLetter, proposedRate, status, appliedAt, updatedAt
  ];
}
