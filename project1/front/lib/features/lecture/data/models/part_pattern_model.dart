import '../../domain/entities/part_pattern.dart';

class PartPatternModel extends PartPattern {
  const PartPatternModel({
    required super.patternId,
    required super.partId,
    required super.startTime,
    required super.endTime,
    required super.rowNum,
    required super.patternText,
  });

  factory PartPatternModel.fromJson(
    Map<String, dynamic> json, {
    required int partId,
  }) => PartPatternModel(
    patternId: json['patternId'] as int,
    partId: partId,
    startTime: json['startTime'] as int,
    endTime: json['endTime'] as int,
    rowNum: json['rowNumber'] as int,
    patternText: json['patternText'] as String,
  );

  Map<String, dynamic> toJson() => {
    'patternId': patternId,
    'startTime': startTime,
    'endTime': endTime,
    'rowNumber': rowNum,
    'patternText': patternText,
  };
}
