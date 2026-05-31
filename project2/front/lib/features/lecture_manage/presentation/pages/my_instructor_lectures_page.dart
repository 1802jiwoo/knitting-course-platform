import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/router/app_router.dart';
import '../../domain/entities/instructor_lecture.dart';
import '../providers/lecture_manage_state.dart';

class MyInstructorLecturesPage extends StatefulWidget {
  const MyInstructorLecturesPage({super.key});

  @override
  State<MyInstructorLecturesPage> createState() =>
      _MyInstructorLecturesPageState();
}

class _MyInstructorLecturesPageState extends State<MyInstructorLecturesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LectureManageState>().loadMyLectures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LectureManageState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 강의 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '강의 등록',
            onPressed: () async {
              await Navigator.pushNamed(context, AppRouter.lectureCreate);
              if (mounted) {
                context.read<LectureManageState>().loadMyLectures();
              }
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(LectureManageState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<LectureManageState>().loadMyLectures(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.lectures.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '등록된 강의가 없습니다',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRouter.lectureCreate);
                if (mounted) {
                  context.read<LectureManageState>().loadMyLectures();
                }
              },
              child: const Text('강의 등록하기'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.lectures.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final lecture = state.lectures[i];
        return _LectureManageCard(
          lecture: lecture,
          onEdit: () async {
            await Navigator.pushNamed(
              context,
              AppRouter.lectureEdit,
              arguments: lecture,
            );
            if (mounted) {
              context.read<LectureManageState>().loadMyLectures();
            }
          },
          onDelete: () => _confirmDelete(lecture),
          onManageParts: lecture.lectureType == 'PATTERN'
              ? null
              : () => Navigator.pushNamed(
                    context,
                    AppRouter.partManage,
                    arguments: {
                      'lectureId': lecture.lectureId,
                      'lectureTitle': lecture.title,
                    },
                  ),
          onManagePatterns: lecture.lectureType == 'PATTERN'
              ? () => Navigator.pushNamed(
                    context,
                    AppRouter.lecturePatternManage,
                    arguments: {
                      'lectureId': lecture.lectureId,
                      'lectureTitle': lecture.title,
                    },
                  )
              : null,
          onQna: () => Navigator.pushNamed(
            context,
            AppRouter.questionDetail,
            arguments: {
              'lectureId': lecture.lectureId,
              'lectureTitle': lecture.title,
            },
          ),
          onSubmit: () => _confirmSubmit(lecture),
        );
      },
    );
  }

  void _confirmDelete(InstructorLecture lecture) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('강의 삭제', style: TextStyle(fontSize: 16)),
        content: Text('"${lecture.title}"을(를) 삭제하시겠습니까?\n삭제 후 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<LectureManageState>()
                  .deleteLecture(lecture.lectureId);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<LectureManageState>().error ?? '삭제에 실패했습니다.',
                    ),
                  ),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit(InstructorLecture lecture) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('검토 요청', style: TextStyle(fontSize: 16)),
        content: const Text('강의를 검토 요청하면 수정이 제한됩니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<LectureManageState>()
                  .submitLecture(lecture.lectureId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '검토 요청이 완료되었습니다.'
                        : (context.read<LectureManageState>().error ??
                            '요청에 실패했습니다.')),
                  ),
                );
              }
            },
            child: const Text('요청'),
          ),
        ],
      ),
    );
  }
}

class _LectureManageCard extends StatelessWidget {
  final InstructorLecture lecture;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onManageParts;
  final VoidCallback? onManagePatterns;
  final VoidCallback onQna;
  final VoidCallback onSubmit;

  const _LectureManageCard({
    required this.lecture,
    required this.onEdit,
    required this.onDelete,
    required this.onManageParts,
    required this.onManagePatterns,
    required this.onQna,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 배지
          Row(
            children: [
              Expanded(
                child: Text(
                  lecture.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: lecture.status),
            ],
          ),
          const SizedBox(height: 8),

          // 유형 + 수강생 + 등록일
          Row(
            children: [
              _TypeChip(lectureType: lecture.lectureType),
              const SizedBox(width: 8),
              Text(
                '수강생 ${lecture.enrollmentCount}명',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              Text(
                '${lecture.createdAt.year}.${lecture.createdAt.month.toString().padLeft(2, '0')}.${lecture.createdAt.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 액션 버튼
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (onManageParts != null)
                _ActionButton(label: '파트 관리', onTap: onManageParts!),
              if (onManagePatterns != null)
                _ActionButton(label: '도안 관리', onTap: onManagePatterns!),
              _ActionButton(label: 'Q&A', onTap: onQna),
              _ActionButton(label: '수정', onTap: onEdit),
              if (lecture.status == 'DRAFT' || lecture.status == 'REJECTED')
                _ActionButton(
                  label: '검토 요청',
                  onTap: onSubmit,
                  color: Colors.blue.shade700,
                ),
              _ActionButton(
                label: '삭제',
                onTap: onDelete,
                color: Colors.red.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'DRAFT' => ('임시저장', Colors.grey.shade600),
      'PENDING' => ('검토 중', Colors.orange.shade700),
      'APPROVED' => ('공개', Colors.green.shade700),
      'REJECTED' => ('반려', Colors.red.shade600),
      'HIDDEN' => ('비공개', Colors.purple.shade600),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String lectureType;

  const _TypeChip({required this.lectureType});

  @override
  Widget build(BuildContext context) {
    final label = switch (lectureType) {
      'PROJECT_CLASS' => '프로젝트',
      'STITCH_BASICS' => '기초 코바늘',
      'PATTERN' => '도안',
      _ => lectureType,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.black54),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: (color ?? Colors.black54).withOpacity(0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.black54,
          ),
        ),
      ),
    );
  }
}
