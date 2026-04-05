import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/question_repository.dart';

class WriteQuestionDialog extends StatefulWidget {
  final int lectureId;
  final VoidCallback onSubmitted;

  const WriteQuestionDialog({
    super.key,
    required this.lectureId,
    required this.onSubmitted,
  });

  @override
  State<WriteQuestionDialog> createState() => WriteQuestionDialogState();
}

class WriteQuestionDialogState extends State<WriteQuestionDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('필수 항목을 입력해 주세요')));
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      final repo = context.read<QuestionRepository>();
      await repo.postQuestion(
        lectureId: widget.lectureId,
        title: title,
        content: content,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('질문이 등록되었습니다')));
        Navigator.pop(context);
        widget.onSubmitted();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('질문 등록에 실패했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: AppColors.background,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: 560,
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                const Text(
                  '질문 작성',
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
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title(),
                    const SizedBox(height: 16),
                    content(),
                    const SizedBox(height: 16),
                    image(),
                    const SizedBox(height: 24),
                    buttons(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '제목',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _titleController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.secondary,
          hintText: '질문 제목을 입력하세요',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedForeground,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    ],
  );

  Widget content() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '내용',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _contentController,
        onChanged: (_) => setState(() {}),
        minLines: 6,
        maxLines: 10,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.secondary,
          hintText: '질문 내용을 입력하세요',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedForeground,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    ],
  );

  Widget image() => Column(
    children: [
      const Text(
        '이미지 (선택사항)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
      const SizedBox(height: 8),
      if (_pickedImage != null)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_pickedImage!.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => setState(() => _pickedImage = null),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.destructiveForeground,
                  ),
                ),
              ),
            ),
          ],
        )
      else
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_outlined,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                SizedBox(width: 6),
                Text(
                  '이미지 업로드',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget buttons() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: AppColors.border),
          ),
          child: const Text(
            '취소',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ElevatedButton(
          onPressed: _canSubmit && !_isSubmitting ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            disabledBackgroundColor: AppColors.border,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryForeground,
                  ),
                )
              : const Text(
                  '질문 등록',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
    ],
  );
}
