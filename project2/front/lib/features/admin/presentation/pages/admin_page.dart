import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_state.dart';
import '../../domain/entities/admin_application.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    return Scaffold(
      appBar: AppBar(title: const Text('강사 신청 관리')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AdminState state) {
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
            title: '강사 신청 승인',
            content: '${app.nickname}의 강사 신청을 승인하시겠습니까?',
            onConfirm: () => context.read<AdminState>().approve(app.applicationId),
          ),
          onReject: () => _confirm(
            title: '강사 신청 거절',
            content: '${app.nickname}의 강사 신청을 거절하시겠습니까?',
            onConfirm: () => context.read<AdminState>().reject(app.applicationId),
          ),
        );
      },
    );
  }

  Future<void> _confirm({
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

    if (confirmed == true && mounted) {
      final success = await onConfirm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '처리되었습니다.' : '오류가 발생했습니다.'),
        ),
      );
    }
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
