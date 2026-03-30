class Enrollment {
  final int enrollmentId;
  final int userId;
  final int lectureId;
  final int progress;
  final DateTime createdAt;

  const Enrollment({
    required this.enrollmentId,
    required this.userId,
    required this.lectureId,
    required this.progress,
    required this.createdAt,
  });
}
