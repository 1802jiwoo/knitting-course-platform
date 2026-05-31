class Enrollment {
  final int enrollmentId;
  final int lectureId;
  final String lectureTitle;
  final String instructorName;
  final String lectureType;
  final String? thumbnailUrl;
  final List<String> tags;
  final List<int> completedPartIds;
  final int totalParts;
  final double progress;
  final DateTime enrolledAt;

  const Enrollment({
    required this.enrollmentId,
    required this.lectureId,
    required this.lectureTitle,
    required this.instructorName,
    required this.lectureType,
    this.thumbnailUrl,
    required this.tags,
    required this.completedPartIds,
    required this.totalParts,
    required this.progress,
    required this.enrolledAt,
  });
}
