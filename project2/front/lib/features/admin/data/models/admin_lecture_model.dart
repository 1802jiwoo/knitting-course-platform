import '../../domain/entities/admin_lecture.dart';

class AdminLectureModel extends AdminLecture {
  const AdminLectureModel({
    required super.lectureId,
    required super.title,
    required super.lectureType,
    required super.status,
    required super.instructorUserId,
    required super.instructorNickname,
    required super.createdAt,
  });

  factory AdminLectureModel.fromJson(Map<String, dynamic> json) {
    return AdminLectureModel(
      lectureId: (json['lectureId'] as num).toInt(),
      title: json['title'] as String,
      lectureType: json['lectureType'] as String,
      status: json['status'] as String,
      instructorUserId: (json['instructorUserId'] as num).toInt(),
      instructorNickname: json['instructorNickname'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
