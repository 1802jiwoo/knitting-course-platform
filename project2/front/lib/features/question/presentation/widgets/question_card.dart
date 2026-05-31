import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:loop_learn/features/question/presentation/widgets/question_detail_dialog.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/answer_repository.dart';
import '../../domain/repositories/question_repository.dart';

class QuestionCard extends StatefulWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  List<Answer> _answers = [];
  Question? _question;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final questionRepo = context.read<QuestionRepository>();
      final answerRepo = context.read<AnswerRepository>();
      final results = await Future.wait([
        questionRepo.getQuestionDetail(widget.question.questionId),
        answerRepo.getAnswers(widget.question.questionId),
      ]);
      if (mounted) {
        setState(() {
          _question = results[0] as Question;
          _answers = results[1] as List<Answer>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openDetail() {
    if (_question == null) return;
    showDialog(
      context: context,
      builder: (_) => QuestionDetailDialog(
        question: _question!,
        initialAnswers: _answers,
        isLoading: _isLoading,
        onAnswersChanged: (updated) {
          if (mounted) setState(() => _answers = updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswer = _answers.isNotEmpty;

    return GestureDetector(
      onTap: _openDetail,
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
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: hasAnswer ? const Color(0xFFDCFCE7) : Colors.transparent,
                      border: Border.all(color: hasAnswer ? Colors.transparent : AppColors.muted),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasAnswer) ...[
                          const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF15803D)),
                          const SizedBox(width: 3),
                          const Text(
                            '답변완료',
                            style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w500),
                          ),
                        ] else
                          Text(
                            '답변대기',
                            style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    widget.question.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.question.nickname}  •  ${widget.question.createdAt.toString().substring(0, 10)}',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
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
