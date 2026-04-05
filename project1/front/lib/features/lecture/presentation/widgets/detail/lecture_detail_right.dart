import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:provider/provider.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/state/app_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../domain/entities/lecture.dart';
import '../../../domain/entities/lecture_part.dart';

class LectureDetailRight extends StatefulWidget {
  const LectureDetailRight({super.key, required this.parts, required this.lectureId, required this.lecture});

  final Lecture lecture;
  final int lectureId;
  final List<LecturePart> parts;

  @override
  State<LectureDetailRight> createState() => _LectureDetailRightState();
}

class _LectureDetailRightState extends State<LectureDetailRight> {

  void _showEnrollDialog(BuildContext context, AppState appState) {
    ConfirmDialog.show(
      context: context,
      title: '수강 신청',
      message: '${widget.lecture.title} 강의를 수강 신청하시겠습니까?',
      confirmText: '확인',
      onConfirm: () => appState.enroll(widget.lectureId),
      variant: ConfirmDialogVariant.defaultVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lecture = widget.lecture;
    final isEnrolled = appState.isEnrolled(widget.lectureId);


    return SizedBox(
      width: context.isTablet ? 320 : double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 20,),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '총 ${widget.parts.length}개 파트',
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isEnrolled) {
                          final totalParts = widget.parts.length;
                          final completedCount = appState.completedPartsFor(widget.lectureId).length;
                          final nextPartIndex = completedCount.clamp(0, totalParts - 1);
                          final nextPartId = widget.parts[nextPartIndex].partId;
                          Navigator.pushNamed(context, AppRouter.lectureWatch, arguments: {
                            'lectureId': widget.lecture.lectureId,
                            'partId': nextPartId,
                            'lectureTitle': widget.lecture.title,
                          });
                        } else {
                          _showEnrollDialog(context, appState);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isEnrolled) ...[
                            const Icon(Icons.play_arrow, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            isEnrolled ? '이어서 듣기' : '수강 신청',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(height: 1, color: Colors.black12),

                  const SizedBox(height: 18),

                  Column(
                    children: [
                      _InfoRow(
                        '난이도',
                        lecture.lectureType == '기초' ? '초급' : '중급',
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        '강의 수',
                        '${widget.parts.length}개',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}