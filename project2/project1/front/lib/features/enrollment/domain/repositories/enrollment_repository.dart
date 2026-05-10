import '../entities/enrollment.dart';

abstract class EnrollmentRepository {
  Future<int> enroll(int lectureId);

  Future<void> cancelEnrollment(int enrollmentId);

  Future<void> completePart({
    required int enrollmentId,
    required int partId,
  });

  Future<List<Enrollment>> getMyEnrollments();
}
