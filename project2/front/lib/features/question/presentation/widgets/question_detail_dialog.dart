import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/presentation/providers/auth_state.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/answer_repository.dart';
import 'answer_card.dart';

class QuestionDetailDialog extends StatefulWidget {
  final Question question;
  final List<Answer> initialAnswers;
  final bool isLoading;
  final void Function(List<Answer> updated)? onAnswersChanged;

  const QuestionDetailDialog({
    super.key,
    required this.question,
    required this.initialAnswers,
    required this.isLoading,
    this.onAnswersChanged,
  });

  @override
  State<QuestionDetailDialog> createState() => _QuestionDetailDialogState();
}

class _QuestionDetailDialogState extends State<QuestionDetailDialog> {
  late List<Answer> _answers;
  final _writeCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _answers = List.from(widget.initialAnswers);
  }

  @override
  void dispose() {
    _writeCtrl.dispose();
    super.dispose();
  }

  void _notifyParent() => widget.onAnswersChanged?.call(_answers);

  Future<void> _submitAnswer() async {
    final content = _writeCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final answer = await context.read<AnswerRepository>().createAnswer(
        widget.question.questionId, content,
      );
      _writeCtrl.clear();
      setState(() { _answers.add(answer); _isSubmitting = false; });
      _notifyParent();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onAnswerUpdated(Answer updated) {
    setState(() {
      final idx = _answers.indexWhere((a) => a.answerId == updated.answerId);
      if (idx >= 0) _answers[idx] = updated;
    });
    _notifyParent();
  }

  void _onAnswerDeleted(int answerId) {
    setState(() => _answers.removeWhere((a) => a.answerId == answerId));
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      child: Container(
        width: 560,
        constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
              child: Row(
                children: [
                  const Text('질문 상세', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.mutedForeground),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: widget.isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(strokeWidth: 2)))
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final auth = context.watch<AuthState>();
    final isInstructor = auth.isLoggedIn && auth.role == 'INSTRUCTOR';
    final q = widget.question;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 질문 섹션 ──────────────────────────────────────
          Text(q.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          const SizedBox(height: 12),
          Text(
            '${q.nickname}  •  ${q.createdAt.toString().substring(0, 10)}',
            style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          Text(q.content, style: const TextStyle(fontSize: 14, color: AppColors.foreground, height: 1.7)),

          if (q.imageUrl != null && q.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                q.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.secondary,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.mutedForeground),
                ),
              ),
            ),
          ],

          // ── 답변 섹션 ──────────────────────────────────────
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 24),

          Row(
            children: [
              const Text('답변', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Text('(${_answers.length})', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 16),

          if (_answers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text('아직 답변이 없습니다', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
              ),
            )
          else
            ...List.generate(_answers.length, (i) => Padding(
              padding: EdgeInsets.only(bottom: i < _answers.length - 1 ? 10 : 0),
              child: AnswerCard(
                answer: _answers[i],
                onUpdated: _onAnswerUpdated,
                onDeleted: _onAnswerDeleted,
              ),
            )),

          // ── 답변 작성 (강사 전용) ──────────────────────────
          if (isInstructor) ...[
            const SizedBox(height: 24),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            const Text('답변 작성', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _writeCtrl,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(hintText: '답변 내용을 입력하세요 (최대 2000자)'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _isSubmitting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('답변 등록', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
