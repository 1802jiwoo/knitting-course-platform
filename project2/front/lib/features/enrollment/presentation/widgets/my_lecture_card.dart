import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:loop_learn/core/theme/app_colors.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/enrollment.dart';
import '../../../lecture/presentation/widgets/shared_widgets.dart';

class MyLectureCard extends StatelessWidget {
  final Enrollment enrollment;
  final VoidCallback onCancel;

  const MyLectureCard({
    super.key,
    required this.enrollment,
    required this.onCancel,
  });

  String _getImage() {
    switch (enrollment.lectureType) {
      case 'STITCH_BASICS':
        return 'https://i.pinimg.com/736x/0d/eb/d8/0debd8a1fdfb48ae02d597c13d5d5e7d.jpg';
      case 'PROJECT_CLASS':
        return 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg';
      case 'PATTERN':
        return 'https://i.pinimg.com/736x/1e/41/cf/1e41cfebfc77d2e2372a270ebcd3844a.jpg';
      default:
        return 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = enrollment.completedPartIds.length;
    final totalParts = enrollment.totalParts;
    final progress = enrollment.progress;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.lectureDetail, arguments: enrollment.lectureId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: context.isTablet ? 260 : 480,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: context.isTablet
            ? Row(children: [_thumbnail(context), _lectureInfo(context, completedCount, totalParts, progress)])
            : Column(children: [_thumbnail(context), _lectureInfo(context, completedCount, totalParts, progress)]),
      ),
    );
  }

  Widget _lectureInfo(BuildContext context, int completedCount, int totalParts, double progress) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LectureTypeBadge(lectureType: enrollment.lectureType),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: const Text(
                  '수강 중',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            enrollment.lectureTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            enrollment.instructorName,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 12),
          const Spacer(),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: enrollment.tags.map((t) => TagPill(label: t)).toList(),
          ),
          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '학습 진도',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  ),
                  Text(
                    '$completedCount/$totalParts 완료 (${(progress * 100).toInt()}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                backgroundColor: AppColors.muted,
                color: AppColors.primary,
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final nextPartIndex = completedCount.clamp(0, totalParts > 0 ? totalParts - 1 : 0);
                  Navigator.pushNamed(
                    context,
                    AppRouter.lectureWatch,
                    arguments: {
                      'lectureId': enrollment.lectureId,
                      'partId': nextPartIndex,
                      'lectureTitle': enrollment.lectureTitle,
                    },
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                label: const Text('이어서 듣기', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '수강 취소',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _thumbnail(BuildContext context) => ClipRRect(
    borderRadius: context.isTablet
        ? const BorderRadius.horizontal(left: Radius.circular(12))
        : const BorderRadius.vertical(top: Radius.circular(12)),
    child: Container(
      height: context.isTablet ? 260 : 200,
      width: context.isTablet ? 260 : double.infinity,
      color: Colors.grey.shade200,
      child: Image.network(_getImage(), fit: BoxFit.cover),
    ),
  );
}
