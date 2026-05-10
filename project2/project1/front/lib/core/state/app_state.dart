import 'package:flutter/foundation.dart';
import '../../features/enrollment/domain/repositories/enrollment_repository.dart';
import '../storage/token_storage.dart';

class AppState extends ChangeNotifier {
  final EnrollmentRepository _repo;
  final TokenStorage _storage;

  Map<int, int> _lectureToEnrollmentId = {};
  Map<int, Set<int>> _completedParts = {};

  AppState({required EnrollmentRepository repo, required TokenStorage storage})
      : _repo = repo,
        _storage = storage {
    if (storage.accessToken != null) _loadEnrollments();
  }

  bool isEnrolled(int lectureId) => _lectureToEnrollmentId.containsKey(lectureId);

  List<int> get enrolledLectureIds => _lectureToEnrollmentId.keys.toList();

  Set<int> completedPartsFor(int lectureId) => _completedParts[lectureId] ?? {};

  double progressFor(int lectureId, int totalParts) {
    if (totalParts == 0) return 0;
    return (_completedParts[lectureId]?.length ?? 0) / totalParts;
  }

  Future<void> _loadEnrollments() async {
    try {
      final list = await _repo.getMyEnrollments();
      _lectureToEnrollmentId = {for (final e in list) e.lectureId: e.enrollmentId};
      _completedParts = {for (final e in list) e.lectureId: e.completedPartIds.toSet()};
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshEnrollments() => _loadEnrollments();

  void clearEnrollments() {
    _lectureToEnrollmentId = {};
    _completedParts = {};
    notifyListeners();
  }

  Future<void> enroll(int lectureId) async {
    final enrollmentId = await _repo.enroll(lectureId);
    _lectureToEnrollmentId[lectureId] = enrollmentId;
    _completedParts[lectureId] = {};
    notifyListeners();
  }

  Future<void> cancelEnrollment(int lectureId) async {
    final enrollmentId = _lectureToEnrollmentId[lectureId];
    if (enrollmentId == null) return;
    await _repo.cancelEnrollment(enrollmentId);
    _lectureToEnrollmentId.remove(lectureId);
    _completedParts.remove(lectureId);
    notifyListeners();
  }

  Future<void> completePart(int lectureId, int partId) async {
    final enrollmentId = _lectureToEnrollmentId[lectureId];
    if (enrollmentId == null) return;
    if (completedPartsFor(lectureId).contains(partId)) return;
    await _repo.completePart(enrollmentId: enrollmentId, partId: partId);
    _completedParts.putIfAbsent(lectureId, () => {});
    _completedParts[lectureId]!.add(partId);
    notifyListeners();
  }
}
