import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:provider/provider.dart';

import '../../../../../core/state/app_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/lecture.dart';
import '../../../domain/entities/lecture_part.dart';
import '../shared_widgets.dart';
import 'lecture_detail_curriculum.dart';
import 'lecture_detail_thumbnail.dart';

class LectureDetailLeft extends StatefulWidget {
  const LectureDetailLeft({
    super.key,
    required this.lecture,
    required this.lectureId,
    required this.parts,
  });

  final Lecture lecture;
  final int lectureId;
  final List<LecturePart> parts;

  @override
  State<LectureDetailLeft> createState() => _LectureDetailLeftState();
}

class _LectureDetailLeftState extends State<LectureDetailLeft> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isEnrolled = appState.isEnrolled(widget.lectureId);

    return Expanded(
      child: context.isTablet
          ? SingleChildScrollView(child: content(isEnrolled))
          : content(isEnrolled),
    );
  }

  Widget content(bool isEnrolled) => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        LectureDetailThumbnail(lectureType: widget.lecture.lectureType),

        const SizedBox(height: 30),

        Row(
          children: [
            LectureTypeBadge(lectureType: widget.lecture.lectureType),

            const SizedBox(width: 6),

            if (isEnrolled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: const Text(
                  '수강 중',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lecture.title,
              style: const TextStyle(
                fontSize: 30, // text-3xl 느낌
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.lecture.instructorName,
              style: const TextStyle(
                fontSize: 18, // text-lg 느낌
                color: AppColors.mutedForeground, // 흐린 색
              ),
            ),

            // const SizedBox(height: 32),
          ],
        ),

        const SizedBox(height: 15),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            widget.lecture.tagNames.length,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#${widget.lecture.tagNames[index]}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '강의 소개',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              widget.lecture.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppColors.foreground,
              ),
            ),

            const SizedBox(height: 32),

            LectureDetailCurriculum(parts: widget.parts),
          ],
        ),

        const VerticalDivider(width: 1),
      ],
    ),
  );
}
