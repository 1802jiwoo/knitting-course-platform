import '../../domain/entities/enrollment.dart';

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.enrollmentId,
    required super.lectureId,
    required super.lectureTitle,
    required super.instructorName,
    required super.lectureType,
    super.thumbnailUrl,
    required super.tags,
    required super.completedPartIds,
    required super.totalParts,
    required super.progress,
    required super.enrolledAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
    enrollmentId: (json['enrollmentId'] as num).toInt(),
    lectureId: (json['lectureId'] as num).toInt(),
    lectureTitle: json['lectureTitle'] as String,
    instructorName: json['instructorName'] as String,
    lectureType: json['lectureType'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    tags: List<String>.from((json['tags'] as List<dynamic>?) ?? []),
    completedPartIds: List<int>.from(
      ((json['completedPartIds'] as List<dynamic>?) ?? []).map((e) => (e as num).toInt()),
    ),
    totalParts: (json['totalParts'] as num).toInt(),
    progress: (json['progress'] as num).toDouble() / 100.0,
    enrolledAt: DateTime.parse(json['enrolledAt'] as String),
  );
}
