import 'package:flutter/foundation.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository _repo;
  final TokenStorage _storage;

  bool _isLoggedIn;
  int? _userId;
  String? _nickname;
  String? _role;
  bool _isLoading = false;
  String? _error;

  AuthState({required AuthRepository repo, required TokenStorage storage})
      : _repo = repo,
        _storage = storage,
        _isLoggedIn = storage.accessToken != null,
        _userId = storage.userId,
        _nickname = storage.nickname,
        _role = storage.role;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get nickname => _nickname;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repo.login(email, password);
      _userId = data.userId;
      _nickname = data.nickname;
      _role = data.role;
      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '로그인에 실패했습니다. 다시 시도해 주세요.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String nickname) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.register(email, password, nickname);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '회원가입에 실패했습니다. 다시 시도해 주세요.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearSession() async {
    await _storage.clear();
    _isLoggedIn = false;
    _userId = null;
    _nickname = null;
    _role = null;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {
      await _storage.clear();
    }
    _isLoggedIn = false;
    _userId = null;
    _nickname = null;
    _role = null;
    notifyListeners();
  }
}
