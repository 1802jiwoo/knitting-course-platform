import '../../domain/entities/instructor_application.dart';

class InstructorApplicationModel extends InstructorApplication {
  const InstructorApplicationModel({
    required super.applicationId,
    required super.bio,
    required super.teachingPlan,
    required super.status,
    required super.createdAt,
  });

  factory InstructorApplicationModel.fromJson(Map<String, dynamic> json) =>
      InstructorApplicationModel(
        applicationId: (json['applicationId'] as num).toInt(),
        bio: json['bio'] as String,
        teachingPlan: json['teachingPlan'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
