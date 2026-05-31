class AdminApplication {
  final int applicationId;
  final int userId;
  final String nickname;
  final String bio;
  final String teachingPlan;
  final String status;
  final DateTime createdAt;

  const AdminApplication({
    required this.applicationId,
    required this.userId,
    required this.nickname,
    required this.bio,
    required this.teachingPlan,
    required this.status,
    required this.createdAt,
  });
}
