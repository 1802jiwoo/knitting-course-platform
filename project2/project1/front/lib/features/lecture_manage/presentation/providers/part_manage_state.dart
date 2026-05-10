import 'package:flutter/foundation.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/instructor_part.dart';
import '../../domain/repositories/part_manage_repository.dart';

class PartManageState extends ChangeNotifier {
  final PartManageRepository _repo;

  List<InstructorPart> _parts = [];
  bool _isLoading = false;
  String? _error;

  PartManageState({required PartManageRepository repo}) : _repo = repo;

  List<InstructorPart> get parts => _parts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadParts(int lectureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _parts = await _repo.getParts(lectureId);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = '파트 목록을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPart({
    required int lectureId,
    required String title,
    String? youtubeUrl,
    int? duration,
  }) async {
    try {
      await _repo.addPart(
        lectureId: lectureId,
        title: title,
        youtubeUrl: youtubeUrl,
        duration: duration,
      );
      await loadParts(lectureId);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = '파트 추가에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePart({
    required int partId,
    required int lectureId,
    String? title,
    String? youtubeUrl,
    int? duration,
  }) async {
    try {
      await _repo.updatePart(
        partId: partId,
        title: title,
        youtubeUrl: youtubeUrl,
        duration: duration,
      );
      await loadParts(lectureId);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = '파트 수정에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePart({required int partId, required int lectureId}) async {
    try {
      await _repo.deletePart(partId);
      await loadParts(lectureId);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = '파트 삭제에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  Future<void> reorderParts({
    required int lectureId,
    required List<int> partIds,
  }) async {
    try {
      await _repo.reorderParts(lectureId: lectureId, partIds: partIds);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (_) {
      _error = '순서 변경에 실패했습니다.';
      notifyListeners();
    }
  }

  void reorderLocal(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = List<InstructorPart>.from(_parts);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _parts = list;
    notifyListeners();
  }
}
