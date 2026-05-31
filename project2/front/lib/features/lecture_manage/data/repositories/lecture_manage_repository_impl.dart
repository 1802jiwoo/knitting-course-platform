import 'dart:typed_data';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/instructor_lecture.dart';
import '../../domain/repositories/lecture_manage_repository.dart';
import '../models/instructor_lecture_model.dart';

class LectureManageRepositoryImpl implements LectureManageRepository {
  final ApiClient _api;

  LectureManageRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<InstructorLecture>> getMyLectures() async {
    final data = await _api.get('/lectures/my') as List<dynamic>;
    return data
        .map((e) => InstructorLectureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> createLecture({
    required String title,
    required String description,
    required String lectureType,
    required List<String> tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  }) async {
    final result = await _api.postMultipart(
      '/lectures',
      jsonFields: {
        'title': title,
        'description': description,
        'lectureType': lectureType,
        'tagNames': tagNames,
      },
      jsonPartName: 'data',
      fileField: thumbnailBytes != null ? 'thumbnail' : null,
      fileBytes: thumbnailBytes,
      fileName: thumbnailFileName ?? 'thumbnail.jpg',
      mimeType: 'image/jpeg',
    ) as Map<String, dynamic>;
    return (result['lectureId'] as num).toInt();
  }

  @override
  Future<void> updateLecture({
    required int lectureId,
    String? title,
    String? description,
    String? lectureType,
    List<String>? tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  }) async {
    await _api.patchMultipart(
      '/lectures/$lectureId',
      jsonFields: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (lectureType != null) 'lectureType': lectureType,
        if (tagNames != null) 'tagNames': tagNames,
      },
      jsonPartName: 'data',
      fileField: thumbnailBytes != null ? 'thumbnail' : null,
      fileBytes: thumbnailBytes,
      fileName: thumbnailFileName ?? 'thumbnail.jpg',
      mimeType: 'image/jpeg',
    );
  }

  @override
  Future<void> deleteLecture(int lectureId) async {
    await _api.delete('/lectures/$lectureId');
  }

  @override
  Future<void> submitLecture(int lectureId) async {
    await _api.post('/lectures/$lectureId/submit');
  }
}
