import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

// ── 공통 네비게이션 바 ────────────────────────────────────────

class LoopLearnNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const LoopLearnNavBar({super.key, required this.currentRoute});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          // 로고
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('LoopLearn',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 24),
          // 강의 목록 탭
          _NavTab(
            label: '강의 목록',
            isActive: currentRoute == AppRouter.lectureList,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRouter.lectureList, (_) => false),
          ),
          const SizedBox(width: 20),
          // 내 강의 탭
          _NavTab(
            label: '내 강의',
            isActive: currentRoute == AppRouter.myLectures,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRouter.myLectures, (_) => false),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.black.withOpacity(0.1)),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.black87 : Colors.black45,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: 40,
            color: isActive ? Colors.black87 : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

// ── 강의 유형 배지 ────────────────────────────────────────────

class LectureTypeBadge extends StatelessWidget {
  final String lectureType;

  const LectureTypeBadge({super.key, required this.lectureType});

  String get _label {
    switch (lectureType) {
      case 'BASIC':   return '기초 학습';
      case 'PROJECT': return '작품 제작';
      case 'PATTERN': return '도안';
      default:        return lectureType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(_label,
          style: const TextStyle(fontSize: 10, color: Colors.black54)),
    );
  }
}

// ── 태그 pill ─────────────────────────────────────────────────

class TagPill extends StatelessWidget {
  final String label;

  const TagPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: Colors.black54)),
    );
  }
}

// ── 진도율 바 ─────────────────────────────────────────────────

class ProgressBar extends StatelessWidget {
  final double value; // 0.0 ~ 1.0
  final int completedParts;
  final int totalParts;

  const ProgressBar({
    super.key,
    required this.value,
    required this.completedParts,
    required this.totalParts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$completedParts / $totalParts 파트 완료',
                style:
                    const TextStyle(fontSize: 10, color: Colors.black45)),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black54),
          ),
        ),
      ],
    );
  }
}
