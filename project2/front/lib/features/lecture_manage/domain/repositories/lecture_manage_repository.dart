import 'dart:typed_data';
import '../entities/instructor_lecture.dart';

abstract class LectureManageRepository {
  Future<List<InstructorLecture>> getMyLectures();
  Future<int> createLecture({
    required String title,
    required String description,
    required String lectureType,
    required List<String> tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  });
  Future<void> updateLecture({
    required int lectureId,
    String? title,
    String? description,
    String? lectureType,
    List<String>? tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  });
  Future<void> deleteLecture(int lectureId);
  Future<void> submitLecture(int lectureId);
}
