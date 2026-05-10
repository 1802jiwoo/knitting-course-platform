import 'pattern_row.dart';

class PartPattern implements PatternRow {
  @override final int patternId;
  final int partId;
  final int startTime;
  final int endTime;
  @override final int rowNum;
  @override final String patternText;

  const PartPattern({
    required this.patternId,
    required this.partId,
    required this.startTime,
    required this.endTime,
    required this.rowNum,
    required this.patternText,
  });
}
