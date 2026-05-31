import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/presentation/providers/auth_state.dart';
import '../../domain/entities/answer.dart';
import '../../domain/repositories/answer_repository.dart';

class AnswerCard extends StatefulWidget {
  final Answer answer;
  final void Function(Answer updated) onUpdated;
  final void Function(int answerId) onDeleted;

  const AnswerCard({
    super.key,
    required this.answer,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool _isEditing = false;
  late TextEditingController _editCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.answer.content);
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  bool get _isOwnAnswer {
    final auth = context.read<AuthState>();
    return auth.isLoggedIn && auth.userId == widget.answer.instructorId;
  }

  Future<void> _save() async {
    final content = _editCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final updated = await context.read<AnswerRepository>().updateAnswer(widget.answer.answerId, content);
      widget.onUpdated(updated);
      if (mounted) setState(() { _isEditing = false; _isSaving = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('답변 삭제'),
        content: const Text('답변을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await context.read<AnswerRepository>().deleteAnswer(widget.answer.answerId);
      widget.onDeleted(widget.answer.answerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwn = _isOwnAnswer;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.muted),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    widget.answer.nickname.isNotEmpty ? widget.answer.nickname[0] : '강',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.answer.nickname,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.answer.createdAt.toString().substring(0, 10),
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              if (isOwn && !_isEditing) ...[
                GestureDetector(
                  onTap: () => setState(() { _isEditing = true; _editCtrl.text = widget.answer.content; }),
                  child: const Text('수정', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _delete,
                  child: const Text('삭제', style: TextStyle(fontSize: 11, color: Colors.red)),
                ),
              ],
            ],
          ),

          if (_isEditing) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _editCtrl,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(hintText: '답변 내용을 입력하세요'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _isSaving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('저장', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 8),
              child: Text(
                widget.answer.content,
                style: const TextStyle(fontSize: 13, color: AppColors.foreground, height: 1.7),
              ),
            ),
        ],
      ),
    );
  }
}
