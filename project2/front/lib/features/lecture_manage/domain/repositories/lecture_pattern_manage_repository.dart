import '../entities/instructor_lecture_pattern.dart';

abstract class LecturePatternManageRepository {
  Future<List<InstructorLecturePattern>> getPatterns(int lectureId);
  Future<int> addPattern({required int lectureId, required String patternText});
  Future<void> updatePattern({required int lectureId, required int patternId, required String patternText});
  Future<void> deletePattern({required int lectureId, required int patternId});
}
