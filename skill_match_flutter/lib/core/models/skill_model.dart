import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  final String? skillId;
  final String skillName;
  final int proficiencyLevel;
  final int? yearsExperience;
  final int endorsementCount;
  final DateTime? createdAt;

  const Skill({
    this.skillId,
    required this.skillName,
    required this.proficiencyLevel,
    this.yearsExperience,
    this.endorsementCount = 0,
    this.createdAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      skillId: json['skillId'] ?? json['skill_id'],
      skillName: json['skillName'] ?? json['skill_name'] ?? '',
      proficiencyLevel: json['proficiencyLevel'] ?? json['proficiency_level'] ?? 1,
      yearsExperience: json['yearsExperience'] ?? json['years_experience'],
      endorsementCount: json['endorsementCount'] ?? json['endorsement_count'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (skillId != null) 'skillId': skillId,
      'skillName': skillName,
      'proficiencyLevel': proficiencyLevel,
      if (yearsExperience != null) 'yearsExperience': yearsExperience,
      'endorsementCount': endorsementCount,
    };
  }

  String get proficiencyLabel {
    switch (proficiencyLevel) {
      case 1:
        return 'Débutant';
      case 2:
        return 'Junior';
      case 3:
        return 'Intermédiaire';
      case 4:
        return 'Senior';
      case 5:
        return 'Expert';
      default:
        return 'Niveau $proficiencyLevel';
    }
  }

  @override
  List<Object?> get props => [skillId, skillName, proficiencyLevel, yearsExperience, endorsementCount, createdAt];
}
