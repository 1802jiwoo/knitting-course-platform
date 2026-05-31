import '../entities/admin_application.dart';

abstract class AdminRepository {
  Future<List<AdminApplication>> getPendingApplications();
  Future<void> approve(int applicationId);
  Future<void> reject(int applicationId);
}
