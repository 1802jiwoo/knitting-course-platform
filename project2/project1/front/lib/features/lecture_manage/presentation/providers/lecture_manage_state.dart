import 'package:flutter/foundation.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/instructor_lecture.dart';
import '../../domain/repositories/lecture_manage_repository.dart';

class LectureManageState extends ChangeNotifier {
  final LectureManageRepository _repo;

  List<InstructorLecture> _lectures = [];
  bool _isLoading = false;
  String? _error;

  LectureManageState({required LectureManageRepository repo}) : _repo = repo;

  List<InstructorLecture> get lectures => _lectures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadMyLectures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _lectures = await _repo.getMyLectures();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = '강의 목록을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLecture({
    required String title,
    required String description,
    required String lectureType,
    required List<String> tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.createLecture(
        title: title,
        description: description,
        lectureType: lectureType,
        tagNames: tagNames,
        thumbnailBytes: thumbnailBytes,
        thumbnailFileName: thumbnailFileName,
      );
      await loadMyLectures();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '강의 등록에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLecture({
    required int lectureId,
    String? title,
    String? description,
    String? lectureType,
    List<String>? tagNames,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.updateLecture(
        lectureId: lectureId,
        title: title,
        description: description,
        lectureType: lectureType,
        tagNames: tagNames,
        thumbnailBytes: thumbnailBytes,
        thumbnailFileName: thumbnailFileName,
      );
      await loadMyLectures();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '강의 수정에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLecture(int lectureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteLecture(lectureId);
      await loadMyLectures();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '강의 삭제에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitLecture(int lectureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.submitLecture(lectureId);
      await loadMyLectures();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = '검토 요청에 실패했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
