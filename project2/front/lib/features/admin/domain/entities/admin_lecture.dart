class AdminLecture {
  final int lectureId;
  final String title;
  final String lectureType;
  final String status;
  final int instructorUserId;
  final String instructorNickname;
  final DateTime createdAt;

  const AdminLecture({
    required this.lectureId,
    required this.title,
    required this.lectureType,
    required this.status,
    required this.instructorUserId,
    required this.instructorNickname,
    required this.createdAt,
  });
}
