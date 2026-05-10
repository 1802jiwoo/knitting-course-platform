class InstructorApplication {
  final int applicationId;
  final String bio;
  final String teachingPlan;
  final String status;
  final DateTime createdAt;

  const InstructorApplication({
    required this.applicationId,
    required this.bio,
    required this.teachingPlan,
    required this.status,
    required this.createdAt,
  });
}
