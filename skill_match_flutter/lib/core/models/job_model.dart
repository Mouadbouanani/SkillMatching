import 'package:equatable/equatable.dart';

enum JobStatus { open, inProgress, completed, cancelled }

class Job extends Equatable {
  final String? id;
  final String requesterId;
  final String title;
  final String description;
  final double budget;
  final String currency;
  final JobStatus status;
  final String? location;
  final DateTime? deadline;
  final List<JobSkill> requiredSkills;
  final Category? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Job({
    this.id,
    required this.requesterId,
    required this.title,
    required this.description,
    required this.budget,
    this.currency = 'MAD',
    this.status = JobStatus.open,
    this.location,
    this.deadline,
    this.requiredSkills = const [],
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      requesterId: json['requesterId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MAD',
      status: _parseStatus(json['status']),
      location: json['location'],
      deadline: json['deadline'] != null 
          ? DateTime.tryParse(json['deadline']) 
          : null,
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)
          ?.map((s) => JobSkill.fromJson(s))
          .toList() ?? [],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'requesterId': requesterId,
      'title': title,
      'description': description,
      'budget': budget,
      'currency': currency,
      'status': status.name.toUpperCase(),
      if (location != null) 'location': location,
      if (deadline != null) 'deadline': deadline!.toIso8601String(),
      'requiredSkills': requiredSkills.map((s) => s.toJson()).toList(),
      if (category != null) 'category': category!.toJson(),
    };
  }

  static JobStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return JobStatus.open;
      case 'IN_PROGRESS':
        return JobStatus.inProgress;
      case 'COMPLETED':
        return JobStatus.completed;
      case 'CANCELLED':
        return JobStatus.cancelled;
      default:
        return JobStatus.open;
    }
  }

  String get statusLabel {
    switch (status) {
      case JobStatus.open:
        return 'Ouvert';
      case JobStatus.inProgress:
        return 'Attribué';
      case JobStatus.completed:
        return 'Terminé';
      case JobStatus.cancelled:
        return 'Annulé';
    }
  }

  String get formattedBudget => '$budget $currency';

  @override
  List<Object?> get props => [
    id, requesterId, title, description, budget, currency, 
    status, location, deadline, requiredSkills, category, createdAt, updatedAt
  ];
}

class JobSkill extends Equatable {
  final String? id;
  final String skillId;
  final String skillName;
  final int requiredLevel;

  const JobSkill({
    this.id,
    this.skillId = 'unknown',
    required this.skillName,
    this.requiredLevel = 1,
  });

  factory JobSkill.fromJson(Map<String, dynamic> json) {
    return JobSkill(
      id: json['id'],
      skillId: json['skillId'] ?? 'unknown',
      skillName: json['skillName'] ?? '',
      requiredLevel: json['requiredLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'skillId': skillId,
      'skillName': skillName,
      'requiredLevel': requiredLevel,
    };
  }

  @override
  List<Object?> get props => [id, skillName, requiredLevel];
}

class Category extends Equatable {
  final String? id;
  final String name;
  final String? description;

  const Category({
    this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, description];
}
