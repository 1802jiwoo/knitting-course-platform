import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/instructor_application.dart';
import '../../domain/repositories/instructor_application_repository.dart';
import '../models/instructor_application_model.dart';

class InstructorApplicationRepositoryImpl
    implements InstructorApplicationRepository {
  final ApiClient _api;

  InstructorApplicationRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<InstructorApplication?> getMyApplication() async {
    try {
      final data = await _api.get('/instructor-applications/me')
          as Map<String, dynamic>;
      return InstructorApplicationModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<InstructorApplication> apply({
    required String bio,
    required String teachingPlan,
  }) async {
    final data = await _api.post(
      '/instructor-applications',
      body: {'bio': bio, 'teachingPlan': teachingPlan},
    ) as Map<String, dynamic>;
    return InstructorApplicationModel.fromJson(data);
  }

  @override
  Future<void> cancel() async {
    await _api.delete('/instructor-applications');
  }
}
