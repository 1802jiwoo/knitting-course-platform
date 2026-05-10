import '../../domain/entities/lecture_pattern.dart';

class LecturePatternModel extends LecturePattern {
  const LecturePatternModel({
    required super.patternId,
    required super.lectureId,
    required super.rowNum,
    required super.patternText,
  });

  factory LecturePatternModel.fromJson(
    Map<String, dynamic> json, {
    required int lectureId,
  }) => LecturePatternModel(
    patternId: json['patternId'] as int,
    lectureId: lectureId,
    rowNum: json['rowNumber'] as int,
    patternText: json['patternText'] as String,
  );

  Map<String, dynamic> toJson() => {
    'patternId': patternId,
    'rowNumber': rowNum,
    'patternText': patternText,
  };
}
