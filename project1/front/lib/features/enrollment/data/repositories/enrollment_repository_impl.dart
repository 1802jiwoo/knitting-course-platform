import '../../domain/repositories/enrollment_repository.dart';
import '../../../../core/network/api_client.dart';
class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final ApiClient _api;

  EnrollmentRepositoryImpl({required ApiClient api}) : _api = api;

  // 수강 신청
  @override
  Future<void> enroll(int lectureId) async {
    await _api.post('/enrollments', body: {'lectureId': lectureId});
  }

  // 수강 취소
  @override
  Future<void> cancelEnrollment(int enrollmentId) async {
    await _api.delete('/enrollments/$enrollmentId');
  }

  // 파트 완료
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
}
