import '../entities/instructor_part.dart';

abstract class PartManageRepository {
  Future<List<InstructorPart>> getParts(int lectureId);
  Future<int> addPart({
    required int lectureId,
    required String title,
    String? youtubeUrl,
    int? duration,
  });
  Future<void> updatePart({
    required int partId,
    String? title,
    String? youtubeUrl,
    int? duration,
  });
  Future<void> deletePart(int partId);
  Future<void> reorderParts({
    required int lectureId,
    required List<int> partIds,
  });
}
