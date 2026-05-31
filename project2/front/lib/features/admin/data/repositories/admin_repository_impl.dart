import '../../../../core/network/api_client.dart';
import '../../domain/entities/admin_application.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_application_model.dart';

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
}
