import '../../../../core/network/api_client.dart';
import '../../domain/entities/instructor_part.dart';
import '../../domain/repositories/part_manage_repository.dart';
import '../models/instructor_part_model.dart';

class PartManageRepositoryImpl implements PartManageRepository {
  final ApiClient _api;

  PartManageRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<InstructorPart>> getParts(int lectureId) async {
    final data = await _api.get('/lectures/$lectureId/parts') as List<dynamic>;
    return data
        .map((e) => InstructorPartModel.fromJson(
              e as Map<String, dynamic>,
              lectureId: lectureId,
            ))
        .toList();
  }

  @override
  Future<int> addPart({
    required int lectureId,
    required String title,
    String? youtubeUrl,
    int? duration,
  }) async {
    final result = await _api.post(
      '/lectures/$lectureId/parts',
      body: {
        'title': title,
        if (youtubeUrl != null && youtubeUrl.isNotEmpty) 'youtubeUrl': youtubeUrl,
        if (duration != null) 'duration': duration,
      },
    ) as Map<String, dynamic>;
    return (result['partId'] as num).toInt();
  }

  @override
  Future<void> updatePart({
    required int partId,
    String? title,
    String? youtubeUrl,
    int? duration,
  }) async {
    await _api.patch(
      '/parts/$partId',
      body: {
        if (title != null) 'title': title,
        if (youtubeUrl != null) 'youtubeUrl': youtubeUrl,
        if (duration != null) 'duration': duration,
      },
    );
  }

  @override
  Future<void> deletePart(int partId) async {
    await _api.delete('/parts/$partId');
  }

  @override
  Future<void> reorderParts({
    required int lectureId,
    required List<int> partIds,
  }) async {
    await _api.patch(
      '/lectures/$lectureId/parts/reorder',
      body: {'partIds': partIds},
    );
  }
}
