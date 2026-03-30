import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../../../lecture/presentation/widgets/shared_widgets.dart';

class MyLecturesPage extends StatefulWidget {
  const MyLecturesPage({super.key});

  @override
  State<MyLecturesPage> createState() => _MyLecturesPageState();
}

class _MyLecturesPageState extends State<MyLecturesPage> {
  // lectureId → (lecture, parts수, tagNames)
  final Map<int, _LectureInfo> _lectureInfoMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledLectures();
  }

  Future<void> _fetchEnrolledLectures() async {
    setState(() => _isLoading = true);
    final appState = context.read<AppState>();
    final enrolledIds = appState.enrolledLectureIds;
    final repo = context.read<LectureRepository>();

    for (final id in enrolledIds) {
      if (_lectureInfoMap.containsKey(id)) continue;
      try {
        final results = await Future.wait([
          repo.getLectureDetail(id),
          repo.getLectureParts(id),
        ]);
        final lecture = results[0] as Lecture;
        final parts = results[1] as List;
        final tagNames = (lecture as dynamic).tagNames as List<String>? ?? [];
        _lectureInfoMap[id] = _LectureInfo(
          lecture: lecture,
          totalParts: parts.length,
          tagNames: tagNames,
        );
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showCancelDialog(BuildContext context, AppState appState, int lectureId, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('수강 취소', style: TextStyle(fontSize: 15)),
        content: Text.rich(TextSpan(children: [
          TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const TextSpan(text: ' 강의를 수강 취소하시겠습니까?\n취소 후 진도 정보도 함께 삭제됩니다.'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('아니오')),
          TextButton(
            onPressed: () {
              appState.cancelEnrollment(lectureId);
              _lectureInfoMap.remove(lectureId);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('취소 확인', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final enrolledIds = appState.enrolledLectureIds;

    return Scaffold(
      appBar: LoopLearnNavBar(currentRoute: AppRouter.myLectures),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(26, 16, 26, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('내 강의', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            const Text('수강 신청한 강의 목록입니다',
                style: TextStyle(fontSize: 12, color: Colors.black45)),
          ]),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : enrolledIds.isEmpty
                ? _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: 0.82,
                    ),
                    itemCount: enrolledIds.length,
                    itemBuilder: (_, i) {
                      final id = enrolledIds[i];
                      final info = _lectureInfoMap[id];
                      if (info == null) return const SizedBox();
                      final completedCount = appState.completedPartsFor(id).length;
                      final progress = appState.progressFor(id, info.totalParts);
                      final isPattern = info.lecture.lectureType == 'PATTERN';

                      return _MyLectureCard(
                        lecture: info.lecture,
                        tags: info.tagNames,
                        completedParts: completedCount,
                        totalParts: info.totalParts,
                        progress: progress,
                        isPattern: isPattern,
                        onCancel: () => _showCancelDialog(
                            context, appState, id, info.lecture.title),
                      );
                    },
                  )),
      ]),
    );
  }
}

class _LectureInfo {
  final Lecture lecture;
  final int totalParts;
  final List<String> tagNames;
  _LectureInfo({required this.lecture, required this.totalParts, required this.tagNames});
}

class _MyLectureCard extends StatelessWidget {
  final Lecture lecture;
  final List<String> tags;
  final int completedParts;
  final int totalParts;
  final double progress;
  final bool isPattern;
  final VoidCallback onCancel;

  const _MyLectureCard({
    required this.lecture, required this.tags,
    required this.completedParts, required this.totalParts,
    required this.progress, required this.isPattern, required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            border: const Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: const Center(child: Icon(Icons.play_circle_outline, size: 30, color: Colors.black26)),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LectureTypeBadge(lectureType: lecture.lectureType),
            const SizedBox(height: 4),
            Text(lecture.title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(lecture.instructorName,
                style: const TextStyle(fontSize: 10, color: Colors.black45)),
            const SizedBox(height: 8),
            isPattern
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('도안 열람 중', style: TextStyle(fontSize: 10, color: Colors.black45)),
                          Text('—', style: TextStyle(fontSize: 10, color: Colors.black45)),
                        ]),
                    const SizedBox(height: 4),
                    Container(height: 4, decoration: BoxDecoration(
                        color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                  ])
                : ProgressBar(value: progress, completedParts: completedParts, totalParts: totalParts),
            const Spacer(),
            Wrap(spacing: 4, runSpacing: 4,
                children: tags.take(2).map((t) => TagPill(label: t)).toList()),
          ]),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(11, 6, 11, 8),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(6)),
                child: const Text('수강 취소', style: TextStyle(fontSize: 11, color: Colors.black45)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.menu_book_outlined, color: Colors.black26),
      ),
      const SizedBox(height: 12),
      const Text('수강 중인 강의가 없습니다',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
      const SizedBox(height: 4),
      const Text('강의 목록에서 원하는 강의를 신청해 보세요',
          style: TextStyle(fontSize: 12, color: Colors.black45)),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.lectureList, (_) => false),
        child: const Text('강의 목록으로'),
      ),
    ]));
  }
}
