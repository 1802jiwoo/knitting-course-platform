import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_state.dart';
import '../../domain/entities/admin_application.dart';
import '../../domain/entities/admin_lecture.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminState>().loadApplications();
      context.read<AdminState>().loadLectures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('관리자'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '강사 신청 관리'),
              Tab(text: '강의 승인'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ApplicationsTab(),
            _LecturesTab(),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

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
              onPressed: () => context.read<AdminState>().loadApplications(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.applications.isEmpty) {
      return const Center(child: Text('처리 대기 중인 강사 신청이 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.applications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final app = state.applications[index];
        return _ApplicationCard(
          application: app,
          onApprove: () => _confirm(
            context: context,
            title: '강사 신청 승인',
            content: '${app.nickname}의 강사 신청을 승인하시겠습니까?',
            onConfirm: () => context.read<AdminState>().approve(app.applicationId),
          ),
          onReject: () => _confirm(
            context: context,
            title: '강사 신청 거절',
            content: '${app.nickname}의 강사 신청을 거절하시겠습니까?',
            onConfirm: () => context.read<AdminState>().reject(app.applicationId),
          ),
        );
      },
    );
  }
}

class _LecturesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    if (state.isLecturesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.lecturesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.lecturesError!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<AdminState>().loadLectures(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.lectures.isEmpty) {
      return const Center(child: Text('검토 요청된 강의가 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.lectures.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lecture = state.lectures[index];
        return _LectureCard(
          lecture: lecture,
          onApprove: () => _confirm(
            context: context,
            title: '강의 승인',
            content: '"${lecture.title}" 강의를 승인하시겠습니까?',
            onConfirm: () => context.read<AdminState>().approveLecture(lecture.lectureId),
          ),
          onReject: () => _confirm(
            context: context,
            title: '강의 거절',
            content: '"${lecture.title}" 강의를 거절하시겠습니까?',
            onConfirm: () => context.read<AdminState>().rejectLecture(lecture.lectureId),
          ),
        );
      },
    );
  }
}

Future<void> _confirm({
  required BuildContext context,
  required String title,
  required String content,
  required Future<bool> Function() onConfirm,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('확인'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    final success = await onConfirm();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '처리되었습니다.' : '오류가 발생했습니다.'),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final AdminApplication application;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final app = application;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                app.nickname,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(width: 8),
              Text(
                '(ID: ${app.userId})',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${app.createdAt.year}.${app.createdAt.month.toString().padLeft(2, '0')}.${app.createdAt.day.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Label(label: '자기소개', value: app.bio),
          const SizedBox(height: 8),
          _Label(label: '강의 계획', value: app.teachingPlan),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('거절'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApprove,
                child: const Text('승인'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  final AdminLecture lecture;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LectureCard({
    required this.lecture,
    required this.onApprove,
    required this.onReject,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  lecture.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Text(
                '${lecture.createdAt.year}.${lecture.createdAt.month.toString().padLeft(2, '0')}.${lecture.createdAt.day.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Label(label: '강사', value: '${lecture.instructorNickname} (ID: ${lecture.instructorUserId})'),
          const SizedBox(height: 8),
          _Label(label: '강의 유형', value: lecture.lectureType),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('거절'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApprove,
                child: const Text('승인'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final String value;

  const _Label({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
