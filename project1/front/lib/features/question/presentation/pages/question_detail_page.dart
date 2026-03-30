import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/question/domain/entities/question.dart';
import '../../../../features/question/domain/entities/answer.dart';
import '../../../../features/question/domain/repositories/question_repository.dart';
import '../../../../features/lecture/presentation/widgets/shared_widgets.dart';
import '../../domain/repositories/answer_repository.dart';

class QuestionDetailPage extends StatefulWidget {
  final int questionId;
  final int lectureId;

  const QuestionDetailPage({super.key, required this.questionId, required this.lectureId});

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  Question? _question;
  Answer? _answer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final questionRepo = context.read<QuestionRepository>();
      final answerRepo = context.read<AnswerRepository>();  // 추가
      final q = await questionRepo.getQuestionDetail(widget.questionId);
      final a = await answerRepo.getAnswer(widget.questionId);
      if (mounted) setState(() { _question = q; _answer = a; _isLoading = false; });

      print(_answer);
      print(widget.questionId);
    } catch (e) {
      if (mounted) setState(() { _error = '질문을 불러오지 못했습니다.'; _isLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('질문 상세', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black.withOpacity(0.1)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: const TextStyle(color: Colors.black45)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _fetchAll, child: const Text('다시 시도')),
      ]))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── 질문 본문 ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Center(child: Text('나',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_question!.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(_question!.createdAt.toString().substring(0, 10),
                      style: const TextStyle(fontSize: 11, color: Colors.black45)),
                ])),
              ]),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Text(_question!.content,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.7)),
            ]),
          ),
          const SizedBox(height: 20),

          // ── 답변 영역 ──────────────────────────────
          Row(children: [
            const Text('답변', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text(_answer != null ? '1개' : '0개',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ]),
          const SizedBox(height: 10),

          if (_answer == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(children: [
                Icon(Icons.chat_bubble_outline, size: 28, color: Colors.black26),
                SizedBox(height: 8),
                Text('아직 답변이 없습니다',
                    style: TextStyle(fontSize: 13, color: Colors.black45)),
                SizedBox(height: 4),
                Text('강사가 답변을 등록하면 여기에 표시됩니다',
                    style: TextStyle(fontSize: 11, color: Colors.black38)),
              ]),
            )
          else
            _AnswerCard(
              content: _answer!.content,
              nickname: _answer!.nickname,
              createdAt: _answer!.createdAt.toString().substring(0, 10),
            ),

          const SizedBox(height: 20),
          // P1 안내
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '답변 작성은 강사만 가능합니다. 답변 기능은 추후 업데이트될 예정입니다.',
              style: TextStyle(fontSize: 11, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ),

          // ── [P2 제안] 답변 작성 폼 ────────────────
          // role == 'INSTRUCTOR' 일 때 표시. P2 인증 연동 후 활성화.
          // ──────────────────────────────────────────
        ]),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String content;
  final String nickname;
  final String createdAt;
  const _AnswerCard({required this.content, required this.nickname, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
            child: const Center(child: Text('강',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
          ),
          const SizedBox(width: 9),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nickname, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(createdAt, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.7)),
      ]),
    );
  }
}