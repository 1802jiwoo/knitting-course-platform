import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final SharedPreferences _prefs;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _nicknameKey = 'nickname';
  static const _roleKey = 'role';

  TokenStorage(this._prefs);

  String? get accessToken => _prefs.getString(_accessKey);
  String? get refreshToken => _prefs.getString(_refreshKey);
  int? get userId => _prefs.getInt(_userIdKey);
  String? get nickname => _prefs.getString(_nicknameKey);
  String? get role => _prefs.getString(_roleKey);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    int? userId,
    String? nickname,
    String? role,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
    if (userId != null) await _prefs.setInt(_userIdKey, userId);
    if (nickname != null) await _prefs.setString(_nicknameKey, nickname);
    if (role != null) await _prefs.setString(_roleKey, role);
  }

  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_nicknameKey);
    await _prefs.remove(_roleKey);
  }
}
