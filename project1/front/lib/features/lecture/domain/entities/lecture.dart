class Lecture {
  final int lectureId;
  final String title;
  final String description;
  final String lectureType;
  final String instructorName;
  final DateTime createdAt;
  final List<String> tagNames;

  const Lecture({
    required this.lectureId,
    required this.title,
    required this.description,
    required this.lectureType,
    required this.instructorName,
    required this.createdAt,
    required this.tagNames,
  });
}
