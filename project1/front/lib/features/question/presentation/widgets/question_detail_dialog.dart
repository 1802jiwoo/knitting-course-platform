import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';

import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import 'answer_card.dart';

class QuestionDetailDialog extends StatefulWidget {
  final Question question;
  final Answer? answer;
  final bool isLoading;

  const QuestionDetailDialog({
    super.key,
    required this.question,
    this.answer,
    required this.isLoading,
  });

  @override
  State<QuestionDetailDialog> createState() => QuestionDetailDialogState();
}

class QuestionDetailDialogState extends State<QuestionDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      child: Container(
        width: 560,
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
              child: Row(
                children: [
                  const Text(
                    '질문 상세',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.mutedForeground,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 콘텐츠
            Flexible(
              child: widget.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _buildContent(widget.question),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Question q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 질문 섹션 ──────────────────────────────────────
          Text(
            q.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),

          // 작성자 · 날짜
          Text(
            '${q.nickname}  •  ${q.createdAt.toString().substring(0, 10)}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),

          // 본문
          Text(
            q.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.foreground,
              height: 1.7,
            ),
          ),

          // 이미지
          if (q.imageUrl != null && q.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                q.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ],

          // ── 답변 섹션 ──────────────────────────────────────
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 24),

          const Text(
            '답변',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.answer == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '아직 답변이 없습니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            AnswerCard(answer: widget.answer!),
        ],
      ),
    );
  }
}
