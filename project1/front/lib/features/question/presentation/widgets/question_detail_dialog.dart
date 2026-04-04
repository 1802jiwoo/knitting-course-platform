import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/answer_repository.dart';
import 'answer_card.dart';

class QuestionDetailDialog extends StatefulWidget {
  final Question question;
  final int lectureId;

  const QuestionDetailDialog({super.key,
    required this.question,
    required this.lectureId,
  });

  @override
  State<QuestionDetailDialog> createState() => QuestionDetailDialogState();
}

class QuestionDetailDialogState extends State<QuestionDetailDialog> {
  Answer? _answer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnswer();
  }

  Future<void> _fetchAnswer() async {
    try {
      final answerRepo = context.read<AnswerRepository>();
      final a = await answerRepo.getAnswer(widget.question.questionId);
      if (mounted)
        setState(() {
          _answer = a;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 0),
              child: Row(
                children: [
                  const Text(
                    '질문 상세',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black45,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 질문 본문
                    Text(
                      q.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          q.userId.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black26,
                            ),
                          ),
                        ),
                        Text(
                          q.createdAt.toString().substring(0, 10),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      q.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                    ),
                    if (q.imageUrl != null && q.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(q.imageUrl!, fit: BoxFit.cover),
                      ),
                    ],

                    // 답변 섹션
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    const Text(
                      '답변',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_answer == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              '아직 답변이 없습니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      AnswerCard(answer: _answer!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}