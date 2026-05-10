class Profile {
  final int userId;
  final String email;
  final String nickname;
  final String role;
  final String? bio;
  final DateTime createdAt;

  const Profile({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.role,
    this.bio,
    required this.createdAt,
  });
}
