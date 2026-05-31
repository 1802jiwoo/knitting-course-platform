import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../features/enrollment/domain/entities/enrollment.dart';
import '../../../../features/enrollment/domain/repositories/enrollment_repository.dart';
import '../../../lecture/presentation/widgets/lecture_nav_bar.dart';
import '../widgets/my_lecture_card.dart';

class MyLecturesPage extends StatefulWidget {
  const MyLecturesPage({super.key});

  @override
  State<MyLecturesPage> createState() => _MyLecturesPageState();
}

class _MyLecturesPageState extends State<MyLecturesPage> {
  List<Enrollment> _enrollments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnrollments();
  }

  Future<void> _fetchEnrollments() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<EnrollmentRepository>();
      final list = await repo.getMyEnrollments();
      if (mounted) setState(() { _enrollments = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCancelDialog(BuildContext context, AppState appState, Enrollment enrollment) {
    ConfirmDialog.show(
      context: context,
      title: '수강 취소',
      message: '정말로 수강을 취소하시겠습니까?',
      warningMessage: '진도 정보가 함께 삭제됩니다.',
      confirmText: '취소하기',
      cancelText: '아니오',
      variant: ConfirmDialogVariant.danger,
      onConfirm: () {
        appState.cancelEnrollment(enrollment.lectureId);
        setState(() {
          _enrollments.removeWhere((e) => e.lectureId == enrollment.lectureId);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LectureNavBar(currentRoute: AppRouter.myLectures),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.isTablet ? 32 : 15, 32, context.isTablet ? 32 : 15, 0,
        ),
        child: CustomScrollView(
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '내 강의',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text('수강 신청한 강의 목록입니다'),
                  SizedBox(height: 32),
                ],
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_enrollments.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final enrollment = _enrollments[i];
                    return MyLectureCard(
                      enrollment: enrollment,
                      onCancel: () => _showCancelDialog(context, appState, enrollment),
                    );
                  },
                  childCount: _enrollments.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
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
