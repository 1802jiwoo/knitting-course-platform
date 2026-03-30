import '../entities/lecture.dart';
import '../entities/lecture_part.dart';
import '../entities/lecture_pattern.dart';
import '../entities/part_pattern.dart';
import '../entities/video.dart';
import '../entities/tag.dart';

abstract class LectureRepository {
  Future<List<Lecture>> getLectures({
    String? title,
    String? tag,
    String? instructor,
  });

  Future<Lecture> getLectureDetail(int lectureId);

  Future<List<LecturePart>> getLectureParts(int lectureId);

  Future<Video> getPartVideo(int partId);

  Future<List<LecturePattern>> getLecturePatterns(int lectureId);

  Future<List<PartPattern>> getPartPatterns(int partId);

  Future<List<Tag>> getTags();
}
