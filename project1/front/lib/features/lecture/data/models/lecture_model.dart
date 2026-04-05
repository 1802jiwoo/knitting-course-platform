import '../../domain/entities/lecture.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.lectureId,
    required super.title,
    required super.description,
    required super.lectureType,
    required super.instructorName,
    required super.createdAt,
    required super.tagNames,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) => LectureModel(
    lectureId: json['lectureId'] as int,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    lectureType: json['lectureType'] as String,
    instructorName: json['instructor'] as String,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    tagNames:
        (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'lectureId': lectureId,
    'title': title,
    'description': description,
    'lectureType': lectureType,
    'instructor': instructorName,
    'tags': tagNames,
  };
}
