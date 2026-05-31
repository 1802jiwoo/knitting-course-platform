import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getMyProfile();
  Future<Profile> updateProfile({String? nickname, String? bio});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deleteAccount({required String password});
}
