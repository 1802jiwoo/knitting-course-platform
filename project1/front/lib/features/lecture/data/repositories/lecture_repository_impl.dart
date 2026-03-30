import '../../domain/entities/lecture.dart';
import '../../domain/entities/lecture_part.dart';
import '../../domain/entities/lecture_pattern.dart';
import '../../domain/entities/part_pattern.dart';
import '../../domain/entities/video.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/lecture_repository.dart';
import '../models/lecture_model.dart';
import '../models/lecture_part_model.dart';
import '../models/lecture_pattern_model.dart';
import '../models/part_pattern_model.dart';
import '../models/video_model.dart';
import '../models/tag_model.dart';
import '../../../../core/network/api_client.dart';

class LectureRepositoryImpl implements LectureRepository {
  final ApiClient _api;

  LectureRepositoryImpl({required ApiClient api}) : _api = api;

  // 강의 가져오기
  @override
  Future<List<Lecture>> getLectures({
    String? title,
    String? tag,
    String? instructor,
  }) async {
    final data = await _api.get(
      '/lectures',
      queryParams: {
        'title': title,
        'tag': tag,
        'instructor': instructor,
      },
    ) as List<dynamic>;

    return data
        .map((e) => LectureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 강의 상세
  @override
  Future<Lecture> getLectureDetail(int lectureId) async {
    final data =
        await _api.get('/lectures/$lectureId') as Map<String, dynamic>;
    return LectureModel.fromJson(data);
  }

  // 강의 파트
  @override
  Future<List<LecturePart>> getLectureParts(int lectureId) async {
    final data =
        await _api.get('/lectures/$lectureId/parts') as List<dynamic>;
    return data
        .map((e) => LecturePartModel.fromJson(
              e as Map<String, dynamic>,
              lectureId: lectureId,
            ))
        .toList();
  }

  // 강의 영상
  @override
  Future<Video> getPartVideo(int partId) async {
    final data =
        await _api.get('/parts/$partId/video') as Map<String, dynamic>;
    return VideoModel.fromJson(data, partId: partId);
  }

  // 강의 패턴
  @override
  Future<List<LecturePattern>> getLecturePatterns(int lectureId) async {
    final data =
        await _api.get('/lectures/$lectureId/patterns') as List<dynamic>;
    return data
        .map((e) => LecturePatternModel.fromJson(
              e as Map<String, dynamic>,
              lectureId: lectureId,
            ))
        .toList();
  }

  // 강의 파트별 패턴
  @override
  Future<List<PartPattern>> getPartPatterns(int partId) async {
    final data =
        await _api.get('/parts/$partId/patterns') as List<dynamic>;
    return data
        .map((e) => PartPatternModel.fromJson(
              e as Map<String, dynamic>,
              partId: partId,
            ))
        .toList();
  }

  // 태그
  @override
  Future<List<Tag>> getTags() async {
    final data = await _api.get('/tags') as List<dynamic>;
    return data
        .asMap()
        .entries
        .map((e) => TagModel.fromString(
              e.value as String,
              index: e.key,
            ))
        .toList();
  }
}
