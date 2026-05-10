import '../../domain/entities/instructor_part_pattern.dart';

class InstructorPartPatternModel extends InstructorPartPattern {
  const InstructorPartPatternModel({
    required super.patternId,
    required super.partId,
    required super.startTime,
    required super.endTime,
    required super.rowNum,
    required super.patternText,
  });

  factory InstructorPartPatternModel.fromJson(
    Map<String, dynamic> json, {
    required int partId,
  }) {
    return InstructorPartPatternModel(
      patternId: (json['patternId'] as num).toInt(),
      partId: partId,
      startTime: (json['startTime'] as num).toInt(),
      endTime: (json['endTime'] as num).toInt(),
      rowNum: (json['rowNumber'] as num).toInt(),
      patternText: json['patternText'] as String,
    );
  }
}
