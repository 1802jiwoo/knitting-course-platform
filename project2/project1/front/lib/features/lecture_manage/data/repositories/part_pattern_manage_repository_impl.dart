import '../../../../core/network/api_client.dart';
import '../../domain/entities/instructor_part_pattern.dart';
import '../../domain/repositories/part_pattern_manage_repository.dart';
import '../models/instructor_part_pattern_model.dart';

class PartPatternManageRepositoryImpl implements PartPatternManageRepository {
  final ApiClient _api;

  PartPatternManageRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<InstructorPartPattern>> getPatterns(int partId) async {
    final data =
        await _api.get('/parts/$partId/patterns') as List<dynamic>;
    return data
        .map((e) => InstructorPartPatternModel.fromJson(
              e as Map<String, dynamic>,
              partId: partId,
            ))
        .toList();
  }

  @override
  Future<int> addPattern({
    required int partId,
    required int startTime,
    required int endTime,
    required String patternText,
  }) async {
    final result = await _api.post(
      '/parts/$partId/patterns',
      body: {
        'startTime': startTime,
        'endTime': endTime,
        'patternText': patternText,
      },
    ) as Map<String, dynamic>;
    return (result['patternId'] as num).toInt();
  }

  @override
  Future<void> updatePattern({
    required int partId,
    required int patternId,
    int? startTime,
    int? endTime,
    String? patternText,
  }) async {
    await _api.patch(
      '/parts/$partId/patterns/$patternId',
      body: {
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (patternText != null) 'patternText': patternText,
      },
    );
  }

  @override
  Future<void> deletePattern({
    required int partId,
    required int patternId,
  }) async {
    await _api.delete('/parts/$partId/patterns/$patternId');
  }
}
