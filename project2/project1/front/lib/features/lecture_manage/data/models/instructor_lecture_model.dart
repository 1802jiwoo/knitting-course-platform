import '../../domain/entities/instructor_lecture.dart';

class InstructorLectureModel extends InstructorLecture {
  const InstructorLectureModel({
    required super.lectureId,
    required super.title,
    required super.description,
    required super.lectureType,
    required super.status,
    super.thumbnailUrl,
    required super.enrollmentCount,
    required super.createdAt,
    required super.tagNames,
  });

  factory InstructorLectureModel.fromJson(Map<String, dynamic> json) =>
      InstructorLectureModel(
        lectureId: (json['lectureId'] as num).toInt(),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        lectureType: json['lectureType'] as String,
        status: json['status'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        enrollmentCount: (json['enrollmentCount'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        tagNames: (json['tagNames'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}
