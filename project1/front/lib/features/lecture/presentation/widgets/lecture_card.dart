import 'package:flutter/material.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/shared_widgets.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../core/theme/app_colors.dart';

class LectureCard extends StatefulWidget {
  final Lecture lecture;
  final bool isEnrolled;
  final VoidCallback onTap;

  const LectureCard({
    super.key,
    required this.lecture,
    required this.isEnrolled,
    required this.onTap,
  });

  @override
  State<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends State<LectureCard> {

  String _getImage() {
    switch (widget.lecture.lectureType) {
      case 'BASIC': return 'https://i.pinimg.com/736x/8c/5b/26/8c5b2668a5e97e3d7e7ef615c2958a72.jpg';
      case 'PROJECT': return 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg';
      case 'PATTERN': return 'https://i.pinimg.com/736x/1e/41/cf/1e41cfebfc77d2e2372a270ebcd3844a.jpg';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                      _getImage(),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12, right: 12,
                      child: LectureTypeBadge(lectureType: widget.lecture.lectureType,),
                    ),
                  ],
                ),
              ),

              // CardContent p-4(16)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        widget.lecture.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 강사명
                      Text(
                        widget.lecture.instructorName,
                        style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                      ),
                      const SizedBox(height: 12),

                      // 태그 (tagNames 필드 추가 시 연결)
                      Wrap(spacing: 8, runSpacing: 8,
                        children: List.generate(widget.lecture.tagNames.length,
                        (index) => TagPill(label: widget.lecture.tagNames[index]),
                      ),),
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