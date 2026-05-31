import 'package:flutter/foundation.dart';
import '../../domain/entities/instructor_lecture_pattern.dart';
import '../../domain/repositories/lecture_pattern_manage_repository.dart';

class LecturePatternManageState extends ChangeNotifier {
  final LecturePatternManageRepository _repo;

  LecturePatternManageState({required LecturePatternManageRepository repo})
      : _repo = repo;

  List<InstructorLecturePattern> _patterns = [];
  bool _isLoading = false;
  String? _error;

  List<InstructorLecturePattern> get patterns => _patterns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadPatterns(int lectureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _patterns = await _repo.getPatterns(lectureId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPattern({
    required int lectureId,
    required String patternText,
  }) async {
    try {
      await _repo.addPattern(lectureId: lectureId, patternText: patternText);
      await loadPatterns(lectureId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePattern({
    required int lectureId,
    required int patternId,
    required String patternText,
  }) async {
    try {
      await _repo.updatePattern(
        lectureId: lectureId,
        patternId: patternId,
        patternText: patternText,
      );
      await loadPatterns(lectureId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePattern({
    required int lectureId,
    required int patternId,
  }) async {
    try {
      await _repo.deletePattern(lectureId: lectureId, patternId: patternId);
      await loadPatterns(lectureId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
