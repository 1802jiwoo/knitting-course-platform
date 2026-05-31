import '../../domain/entities/admin_application.dart';

class AdminApplicationModel extends AdminApplication {
  const AdminApplicationModel({
    required super.applicationId,
    required super.userId,
    required super.nickname,
    required super.bio,
    required super.teachingPlan,
    required super.status,
    required super.createdAt,
  });

  factory AdminApplicationModel.fromJson(Map<String, dynamic> json) {
    return AdminApplicationModel(
      applicationId: (json['applicationId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      bio: json['bio'] as String,
      teachingPlan: json['teachingPlan'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
