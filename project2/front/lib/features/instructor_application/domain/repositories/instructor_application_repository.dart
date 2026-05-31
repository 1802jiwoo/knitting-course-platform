import '../entities/instructor_application.dart';

abstract class InstructorApplicationRepository {
  Future<InstructorApplication?> getMyApplication();
  Future<InstructorApplication> apply({required String bio, required String teachingPlan});
  Future<void> cancel();
}
