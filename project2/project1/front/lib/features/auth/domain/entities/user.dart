class User {
  final int userId;
  final String email;
  final String nickname;
  final String role;
  final DateTime createdAt;

  const User({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.role,
    required this.createdAt,
  });
}
