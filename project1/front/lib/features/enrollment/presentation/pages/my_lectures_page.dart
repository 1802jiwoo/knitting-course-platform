import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/lecture_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../../../lecture/presentation/widgets/shared_widgets.dart';
import '../widgets/my_lecture_card.dart';

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

  void _showCancelDialog(
    BuildContext context,
    AppState appState,
    int lectureId,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('수강 취소', style: TextStyle(fontSize: 15)),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' 강의를 수강 취소하시겠습니까?\n취소 후 진도 정보도 함께 삭제됩니다.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              appState.cancelEnrollment(lectureId);
              _lectureInfoMap.remove(lectureId);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text(
              '취소 확인',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
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
      backgroundColor: AppColors.background,
      appBar: LectureNavBar(currentRoute: AppRouter.myLectures),
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.isTablet ? 32 : 15, 32, context.isTablet ? 32 : 15, 0,),
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '내 강의',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text('수강 신청한 강의 목록입니다'),
                  SizedBox(height: 32,),
                ],
              ),
            ),


            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (enrolledIds.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyState(),
              )
            else SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final id = enrolledIds[i];
                final info = _lectureInfoMap[id];

                if (info == null) return const SizedBox();

                final progress = appState.progressFor(id, info.totalParts);

                final isPattern = info.lecture.lectureType == 'PATTERN';
                final completedCount = appState.completedPartsFor(id).length;

                return MyLectureCard(
                  lecture: info.lecture,
                  tags: info.tagNames,
                  completedParts: completedCount,
                  totalParts: info.totalParts,
                  progress: progress,
                  isPattern: isPattern,
                  onCancel: () => _showCancelDialog(
                    context,
                    appState,
                    id,
                    info.lecture.title,
                  ),
                );
              }, childCount: enrolledIds.length),
            ),
          ],
        ),
      ),
    );
  }
}

class _LectureInfo {
  final Lecture lecture;
  final int totalParts;
  final List<String> tagNames;

  _LectureInfo({
    required this.lecture,
    required this.totalParts,
    required this.tagNames,
  });
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_outlined, color: Colors.black26),
          ),
          const SizedBox(height: 12),
          const Text(
            '수강 중인 강의가 없습니다',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '강의 목록에서 원하는 강의를 신청해 보세요',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.lectureList,
              (_) => false,
            ),
            child: const Text('강의 목록으로'),
          ),
        ],
      ),
    );
  }
}
