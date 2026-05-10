import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.email,
    required super.nickname,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['user_id'] as int,
        email: json['email'] as String,
        nickname: json['nickname'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'nickname': nickname,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };
}
