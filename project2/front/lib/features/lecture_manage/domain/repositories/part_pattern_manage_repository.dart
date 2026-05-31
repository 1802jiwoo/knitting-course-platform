import '../entities/instructor_part_pattern.dart';

abstract class PartPatternManageRepository {
  Future<List<InstructorPartPattern>> getPatterns(int partId);
  Future<int> addPattern({
    required int partId,
    required int startTime,
    required int endTime,
    required String patternText,
  });
  Future<void> updatePattern({
    required int partId,
    required int patternId,
    int? startTime,
    int? endTime,
    String? patternText,
  });
  Future<void> deletePattern({required int partId, required int patternId});
}
