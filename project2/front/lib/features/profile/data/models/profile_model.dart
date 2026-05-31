import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.userId,
    required super.email,
    required super.nickname,
    required super.role,
    super.bio,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        userId: (json['userId'] as num).toInt(),
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        role: json['role'] as String,
        bio: json['bio'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
