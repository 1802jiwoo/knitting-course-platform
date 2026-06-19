import '../entities/admin_application.dart';
import '../entities/admin_lecture.dart';

abstract class AdminRepository {
  Future<List<AdminApplication>> getPendingApplications();
  Future<void> approve(int applicationId);
  Future<void> reject(int applicationId);

  Future<List<AdminLecture>> getPendingLectures();
  Future<void> approveLecture(int lectureId);
  Future<void> rejectLecture(int lectureId);
}
