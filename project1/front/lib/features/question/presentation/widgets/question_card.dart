import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';

import '../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const QuestionCard({super.key, required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // final hasAnswer = question.hasAnswer; // bool 필드 또는 getter
    final hasAnswer = false; // 임시

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.muted),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 답변 상태 배지
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: hasAnswer
                          ? const Color(0xFFDCFCE7)
                          : Colors.transparent,
                      border: hasAnswer
                          ? null
                          : Border.all(color: AppColors.muted),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasAnswer) ...[
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Color(0xFF15803D),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            '답변완료',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else
                          Text(
                            '답변대기',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    question.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${question.userId}  •  ${question.createdAt.toString().substring(0, 10)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            // 이미지 썸네일 (있을 때만)
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  question.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}