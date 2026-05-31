import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../../../core/network/api_client.dart';
import '../models/enrollment_model.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final ApiClient _api;

  EnrollmentRepositoryImpl({required ApiClient api}) : _api = api;

  @override
  Future<int> enroll(int lectureId) async {
    final data = await _api.post('/enrollments', body: {'lectureId': lectureId});
    return (data['enrollmentId'] as num).toInt();
  }

  @override
  Future<void> cancelEnrollment(int enrollmentId) async {
    await _api.delete('/enrollments/$enrollmentId');
  }

  @override
  Future<void> completePart({
    required int enrollmentId,
    required int partId,
  }) async {
    await _api.post(
      '/enrollments/$enrollmentId/complete-part',
      body: {'partId': partId},
    );
  }

  @override
  Future<List<Enrollment>> getMyEnrollments() async {
    final data = await _api.get('/enrollments/my');
    return (data as List<dynamic>)
        .map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
