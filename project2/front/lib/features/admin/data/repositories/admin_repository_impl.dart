import '../../../../core/network/api_client.dart';
import '../../domain/entities/admin_application.dart';
import '../../domain/entities/admin_lecture.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_application_model.dart';
import '../models/admin_lecture_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiClient _api;

  AdminRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<List<AdminApplication>> getPendingApplications() async {
    final data = await _api.get('/admin/instructor-applications') as List<dynamic>;
    return data
        .map((e) => AdminApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approve(int applicationId) async {
    await _api.post('/admin/instructor-applications/$applicationId/approve');
  }

  @override
  Future<void> reject(int applicationId) async {
    await _api.post('/admin/instructor-applications/$applicationId/reject');
  }

  @override
  Future<List<AdminLecture>> getPendingLectures() async {
    final data = await _api.get('/admin/lectures') as List<dynamic>;
    return data
        .map((e) => AdminLectureModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveLecture(int lectureId) async {
    await _api.post('/admin/lectures/$lectureId/approve');
  }

  @override
  Future<void> rejectLecture(int lectureId) async {
    await _api.post('/admin/lectures/$lectureId/reject');
  }
}
