import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _api;

  ProfileRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<Profile> getMyProfile() async {
    final data = await _api.get('/profile/me') as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<Profile> updateProfile({String? nickname, String? bio}) async {
    final body = <String, dynamic>{};
    if (nickname != null) body['nickname'] = nickname;
    if (bio != null) body['bio'] = bio;

    final data = await _api.patch('/profile/me', body: body) as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.patch('/profile/password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    await _api.deleteWithBody('/profile/me', body: {'password': password});
  }
}
