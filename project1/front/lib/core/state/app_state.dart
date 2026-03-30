import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Set<int> _enrolledLectureIds = {};
  Map<int, Set<int>> _completedParts = {};

  AppState() {
    _load();
  }

  // 저장 / 불러오기
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _enrolledLectureIds = (prefs.getStringList('enrolled') ?? [])
        .map(int.parse)
        .toSet();

    final partsJson = prefs.getString('completedParts');
    if (partsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(partsJson);
      _completedParts = decoded.map(
        (k, v) => MapEntry(int.parse(k), Set<int>.from(v)),
      );
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'enrolled',
      _enrolledLectureIds.map((e) => e.toString()).toList(),
    );

    await prefs.setString(
      'completedParts',
      jsonEncode(
        _completedParts.map((k, v) => MapEntry(k.toString(), v.toList())),
      ),
    );
  }

  // 수강 신청

  bool isEnrolled(int lectureId) => _enrolledLectureIds.contains(lectureId);

  List<int> get enrolledLectureIds => _enrolledLectureIds.toList();

  void enroll(int lectureId) {
    if (!_enrolledLectureIds.contains(lectureId)) {
      _enrolledLectureIds.add(lectureId);
      _completedParts[lectureId] = {};
      _save();
      notifyListeners();
    }
  }

  void cancelEnrollment(int lectureId) {
    _enrolledLectureIds.remove(lectureId);
    _completedParts.remove(lectureId);
    _save();
    notifyListeners();
  }

  // 진도율

  Set<int> completedPartsFor(int lectureId) => _completedParts[lectureId] ?? {};

  void completePart(int lectureId, int partId) {
    _completedParts.putIfAbsent(lectureId, () => {});
    _completedParts[lectureId]!.add(partId);
    _save();
    notifyListeners();
  }

  double progressFor(int lectureId, int totalParts) {
    if (totalParts == 0) return 0;
    final done = _completedParts[lectureId]?.length ?? 0;
    return done / totalParts;
  }
}
