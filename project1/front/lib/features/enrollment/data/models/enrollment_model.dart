import '../../domain/entities/enrollment.dart';

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.enrollmentId,
    required super.userId,
    required super.lectureId,
    required super.progress,
    required super.createdAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        enrollmentId: json['enrollment_id'] as int,
        userId: json['user_id'] as int,
        lectureId: json['lecture_id'] as int,
        progress: json['progress'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'enrollment_id': enrollmentId,
    'user_id': userId,
    'lecture_id': lectureId,
    'progress': progress,
    'created_at': createdAt.toIso8601String(),
  };
}
