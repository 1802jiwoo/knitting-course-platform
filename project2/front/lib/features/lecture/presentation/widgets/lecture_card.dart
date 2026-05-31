import 'package:flutter/material.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/shared_widgets.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../core/theme/app_colors.dart';

class LectureCard extends StatelessWidget {
  final Lecture lecture;
  final bool isEnrolled;
  final VoidCallback onTap;

  const LectureCard({
    super.key,
    required this.lecture,
    required this.isEnrolled,
    required this.onTap,
  });

  static const _fallbackImages = {
    'STITCH_BASICS': 'https://i.pinimg.com/736x/8c/5b/26/8c5b2668a5e97e3d7e7ef615c2958a72.jpg',
    'PROJECT_CLASS': 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg',
    'PATTERN': 'https://i.pinimg.com/736x/1e/41/cf/1e41cfebfc77d2e2372a270ebcd3844a.jpg',
  };

  String get _imageUrl {
    if (lecture.thumbnailUrl != null && lecture.thumbnailUrl!.isNotEmpty) {
      return lecture.thumbnailUrl!;
    }
    return _fallbackImages[lecture.lectureType] ?? _fallbackImages['PROJECT_CLASS']!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: LectureTypeBadge(lectureType: lecture.lectureType),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lecture.instructorName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.mutedForeground),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: lecture.tagNames
                            .map((t) => TagPill(label: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
