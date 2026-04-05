import 'package:flutter/material.dart';
import 'package:loop_learn/core/router/app_router.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/lecture_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../../features/question/domain/entities/question.dart';
import '../../../../features/question/domain/repositories/question_repository.dart';
import '../widgets/question_card.dart';
import '../widgets/question_detail_dialog.dart';
import '../widgets/write_question_dialog.dart';

class QuestionPage extends StatefulWidget {
  final int lectureId;
  final String lectureTitle;

  const QuestionPage({
    super.key,
    required this.lectureId,
    required this.lectureTitle,
  });

  @override
  State<QuestionPage> createState() => QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final questionRepo = context.read<QuestionRepository>();
      final list = await questionRepo.getQuestions(widget.lectureId);
      if (mounted) {
        setState(() {
          _questions = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '질문 목록을 불러오지 못했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  void _openWriteDialog() {
    showDialog(
      context: context,
      builder: (_) => WriteQuestionDialog(
        lectureId: widget.lectureId,
        onSubmitted: _fetchQuestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LectureNavBar(currentRoute: AppRouter.questionDetail),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.black45)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _fetchQuestions,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
                : _questions.isEmpty
                ? _buildEmptyState()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.black54),
            label: const Text(
              '강의로 돌아가기',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '질문과 답변',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lectureTitle,
                      style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _openWriteDialog,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('질문 작성'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            const Text(
              '아직 질문이 없습니다',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '강의에 대해 궁금한 점이 있다면 질문해보세요!',
              style: TextStyle(fontSize: 12, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openWriteDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('첫 질문 작성하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _questions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => QuestionCard(
        question: _questions[i],
      ),
    );
  }
}