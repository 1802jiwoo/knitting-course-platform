import 'package:flutter/foundation.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState extends ChangeNotifier {
  final ProfileRepository _repo;

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileState({required ProfileRepository repo}) : _repo = repo;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repo.getMyProfile();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = '프로필을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? nickname, String? bio}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repo.updateProfile(nickname: nickname, bio: bio);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '프로필 수정에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '비밀번호 변경에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.deleteAccount(password: password);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '회원 탈퇴에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
