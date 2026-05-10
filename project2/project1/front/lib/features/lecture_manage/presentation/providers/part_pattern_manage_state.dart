import 'package:flutter/foundation.dart';
import '../../domain/entities/instructor_part_pattern.dart';
import '../../domain/repositories/part_pattern_manage_repository.dart';

class PartPatternManageState extends ChangeNotifier {
  final PartPatternManageRepository _repo;

  PartPatternManageState({required PartPatternManageRepository repo})
      : _repo = repo;

  List<InstructorPartPattern> _patterns = [];
  bool _isLoading = false;
  String? _error;

  List<InstructorPartPattern> get patterns => _patterns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadPatterns(int partId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _patterns = await _repo.getPatterns(partId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPattern({
    required int partId,
    required int startTime,
    required int endTime,
    required String patternText,
  }) async {
    try {
      await _repo.addPattern(
        partId: partId,
        startTime: startTime,
        endTime: endTime,
        patternText: patternText,
      );
      await loadPatterns(partId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePattern({
    required int partId,
    required int patternId,
    int? startTime,
    int? endTime,
    String? patternText,
  }) async {
    try {
      await _repo.updatePattern(
        partId: partId,
        patternId: patternId,
        startTime: startTime,
        endTime: endTime,
        patternText: patternText,
      );
      await loadPatterns(partId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePattern({
    required int partId,
    required int patternId,
  }) async {
    try {
      await _repo.deletePattern(partId: partId, patternId: patternId);
      await loadPatterns(partId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
