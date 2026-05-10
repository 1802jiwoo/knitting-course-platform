import '../entities/login_data.dart';

abstract class AuthRepository {
  Future<LoginData> login(String email, String password);
  Future<void> register(String email, String password, String nickname);
  Future<void> logout();
}
