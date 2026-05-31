import '../../domain/entities/instructor_lecture_pattern.dart';

class InstructorLecturePatternModel extends InstructorLecturePattern {
  const InstructorLecturePatternModel({
    required super.patternId,
    required super.lectureId,
    required super.rowNum,
    required super.patternText,
  });

  factory InstructorLecturePatternModel.fromJson(
    Map<String, dynamic> json, {
    required int lectureId,
  }) {
    return InstructorLecturePatternModel(
      patternId: (json['patternId'] as num).toInt(),
      lectureId: lectureId,
      rowNum: (json['rowNumber'] as num).toInt(),
      patternText: json['patternText'] as String,
    );
  }
}
