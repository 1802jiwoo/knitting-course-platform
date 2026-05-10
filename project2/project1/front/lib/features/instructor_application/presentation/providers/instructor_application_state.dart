import 'package:flutter/foundation.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/instructor_application.dart';
import '../../domain/repositories/instructor_application_repository.dart';

class InstructorApplicationState extends ChangeNotifier {
  final InstructorApplicationRepository _repo;

  InstructorApplication? _application;
  bool _isLoading = false;
  String? _error;

  InstructorApplicationState({required InstructorApplicationRepository repo})
      : _repo = repo;

  InstructorApplication? get application => _application;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _application = await _repo.getMyApplication();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = '신청 상태를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> apply({required String bio, required String teachingPlan}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _application = await _repo.apply(bio: bio, teachingPlan: teachingPlan);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '강사 신청에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.cancel();
      _application = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '신청 취소에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
