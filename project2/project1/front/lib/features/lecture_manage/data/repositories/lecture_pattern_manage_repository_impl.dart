import '../../../../core/network/api_client.dart';
import '../../domain/entities/instructor_lecture_pattern.dart';
import '../../domain/repositories/lecture_pattern_manage_repository.dart';
import '../models/instructor_lecture_pattern_model.dart';

class LecturePatternManageRepositoryImpl
    implements LecturePatternManageRepository {
  final ApiClient _api;

  LecturePatternManageRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<InstructorLecturePattern>> getPatterns(int lectureId) async {
    final data =
        await _api.get('/lectures/$lectureId/patterns') as List<dynamic>;
    return data
        .map((e) => InstructorLecturePatternModel.fromJson(
              e as Map<String, dynamic>,
              lectureId: lectureId,
            ))
        .toList();
  }

  @override
  Future<int> addPattern({
    required int lectureId,
    required String patternText,
  }) async {
    final result = await _api.post(
      '/lectures/$lectureId/patterns',
      body: {'patternText': patternText},
    ) as Map<String, dynamic>;
    return (result['patternId'] as num).toInt();
  }

  @override
  Future<void> updatePattern({
    required int lectureId,
    required int patternId,
    required String patternText,
  }) async {
    await _api.patch(
      '/lectures/$lectureId/patterns/$patternId',
      body: {'patternText': patternText},
    );
  }

  @override
  Future<void> deletePattern({
    required int lectureId,
    required int patternId,
  }) async {
    await _api.delete('/lectures/$lectureId/patterns/$patternId');
  }
}
