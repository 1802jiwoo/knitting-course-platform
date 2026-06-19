import 'package:flutter/material.dart';
import '../../domain/entities/admin_application.dart';
import '../../domain/entities/admin_lecture.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminState extends ChangeNotifier {
  final AdminRepository _repo;

  AdminState({required AdminRepository repo}) : _repo = repo;

  List<AdminApplication> applications = [];
  bool isLoading = false;
  String? error;

  List<AdminLecture> lectures = [];
  bool isLecturesLoading = false;
  String? lecturesError;

  Future<void> loadApplications() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      applications = await _repo.getPendingApplications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(int applicationId) async {
    try {
      await _repo.approve(applicationId);
      applications.removeWhere((a) => a.applicationId == applicationId);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(int applicationId) async {
    try {
      await _repo.reject(applicationId);
      applications.removeWhere((a) => a.applicationId == applicationId);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadLectures() async {
    isLecturesLoading = true;
    lecturesError = null;
    notifyListeners();
    try {
      lectures = await _repo.getPendingLectures();
    } catch (e) {
      lecturesError = e.toString();
    } finally {
      isLecturesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveLecture(int lectureId) async {
    try {
      await _repo.approveLecture(lectureId);
      lectures.removeWhere((l) => l.lectureId == lectureId);
      notifyListeners();
      return true;
    } catch (e) {
      lecturesError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectLecture(int lectureId) async {
    try {
      await _repo.rejectLecture(lectureId);
      lectures.removeWhere((l) => l.lectureId == lectureId);
      notifyListeners();
      return true;
    } catch (e) {
      lecturesError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
