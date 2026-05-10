class InstructorLecture {
  final int lectureId;
  final String title;
  final String description;
  final String lectureType;
  final String status;
  final String? thumbnailUrl;
  final int enrollmentCount;
  final DateTime createdAt;
  final List<String> tagNames;

  const InstructorLecture({
    required this.lectureId,
    required this.title,
    required this.description,
    required this.lectureType,
    required this.status,
    this.thumbnailUrl,
    required this.enrollmentCount,
    required this.createdAt,
    required this.tagNames,
  });
}
