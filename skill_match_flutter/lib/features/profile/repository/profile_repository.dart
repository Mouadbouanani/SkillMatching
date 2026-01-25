import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/models/skill_model.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<Profile> createProfile({
    required String displayName,
    String? bio,
    String? location,
    String? availability,
    String? profilePictureUrl,
  }) async {
    final response = await _apiClient.createProfile(
      displayName: displayName,
      bio: bio,
      location: location,
      availability: availability,
      profilePictureUrl: profilePictureUrl,
    );
    return Profile.fromJson(response.data);
  }

  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _apiClient.getProfile(userId);
      return Profile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Profile> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _apiClient.updateProfile(userId, data);
    return Profile.fromJson(response.data);
  }

  Future<void> addSkill(String userId, Skill skill) async {
    await _apiClient.addSkill(
      userId,
      skillName: skill.skillName,
      proficiencyLevel: skill.proficiencyLevel,
      yearsExperience: skill.yearsExperience,
    );
  }
}
