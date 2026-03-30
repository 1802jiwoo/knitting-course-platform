abstract class EnrollmentRepository {
  Future<void> enroll(int lectureId);

  Future<void> cancelEnrollment(int enrollmentId);

  Future<void> completePart({
    required int enrollmentId,
    required int partId,
  });
}
