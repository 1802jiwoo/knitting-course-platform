import 'pattern_row.dart';

class LecturePattern implements PatternRow {
  @override final int patternId;
  final int lectureId;
  @override final int rowNum;
  @override final String patternText;

  const LecturePattern({
    required this.patternId,
    required this.lectureId,
    required this.rowNum,
    required this.patternText,
  });
}
