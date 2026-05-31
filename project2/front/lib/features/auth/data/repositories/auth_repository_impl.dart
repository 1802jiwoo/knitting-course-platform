import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/login_data.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepositoryImpl({required ApiClient api, required TokenStorage storage})
      : _api = api,
        _storage = storage;

  @override
  Future<LoginData> login(String email, String password) async {
    final data = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final userId = (data['userId'] as num).toInt();
    final nickname = data['nickname'] as String;
    final role = data['role'] as String;

    await _storage.save(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      userId: userId,
      nickname: nickname,
      role: role,
    );

    return LoginData(userId: userId, nickname: nickname, role: role);
  }

  @override
  Future<void> register(String email, String password, String nickname) async {
    await _api.post('/auth/signup', body: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await _storage.clear();
    }
  }
}
