import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../features/lecture/domain/entities/lecture_part.dart';
import '../../../../features/lecture/domain/entities/tag.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../../../../features/question/domain/entities/question.dart';
import '../../../../features/question/domain/repositories/question_repository.dart';
import '../widgets/shared_widgets.dart';

class LectureDetailPage extends StatefulWidget {
  final int lectureId;
  const LectureDetailPage({super.key, required this.lectureId});

  @override
  State<LectureDetailPage> createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  // API 상태
  Lecture? _lecture;
  List<LecturePart> _parts = [];
  List<Question> _questions = [];
  List<Tag> _tags = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final lectureRepo = context.read<LectureRepository>();
      final questionRepo = context.read<QuestionRepository>();
      final results = await Future.wait([
        lectureRepo.getLectureDetail(widget.lectureId),
        lectureRepo.getLectureParts(widget.lectureId),
        questionRepo.getQuestions(widget.lectureId),
      ]);
      if (mounted) {
        setState(() {
          _lecture = results[0] as Lecture;
          _parts   = results[1] as List<LecturePart>;
          _questions = results[2] as List<Question>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '강의 정보를 불러오지 못했습니다.'; _isLoading = false; });
    }
  }

  void _showEnrollDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('수강 신청', style: TextStyle(fontSize: 15)),
        content: Text.rich(TextSpan(children: [
          TextSpan(text: _lecture!.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const TextSpan(text: ' 강의를 수강 신청하시겠습니까?'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('아니오')),
          TextButton(
            onPressed: () {
              appState.enroll(widget.lectureId);
              Navigator.pop(context);
            },
            child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuestion(BuildContext context, AppState appState) async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 입력해 주세요')));
      return;
    }
    try {
      final repo = context.read<QuestionRepository>();
      await repo.postQuestion(
        lectureId: widget.lectureId,
        title: title,
        content: content,
      );
      _titleCtrl.clear();
      _contentCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문이 등록되었습니다')));
      // 질문 목록 새로고침
      final newQs = await repo.getQuestions(widget.lectureId);
      if (mounted) setState(() => _questions = newQs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문 등록에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(
      appBar: LoopLearnNavBar(currentRoute: AppRouter.lectureList),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: const TextStyle(color: Colors.black45)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _fetchAll, child: const Text('다시 시도')),
      ])),
    );

    final appState = context.watch<AppState>();
    final lecture = _lecture!;
    final isEnrolled = appState.isEnrolled(widget.lectureId);

    // API LectureModel의 tagNames 추출
    final tagNames = (lecture as dynamic).tagNames as List<String>? ?? [];

    return Scaffold(
      appBar: LoopLearnNavBar(currentRoute: AppRouter.lectureList),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 좌측 ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 브레드크럼
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, AppRouter.lectureList, (_) => false),
                      child: const Text('강의 목록',
                          style: TextStyle(fontSize: 11, color: Colors.black45)),
                    ),
                    const Text(' › ', style: TextStyle(fontSize: 11, color: Colors.black45)),
                    Text(lecture.title,
                        style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ]),
                  const SizedBox(height: 14),
                  // 썸네일
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Center(child: Icon(Icons.play_circle_outline, size: 48, color: Colors.black26)),
                  ),
                  const SizedBox(height: 14),
                  LectureTypeBadge(lectureType: lecture.lectureType),
                  const SizedBox(height: 6),
                  Text(lecture.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(lecture.instructorName,
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 5, children: tagNames.map((t) => TagPill(label: t)).toList()),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lecture.description,
                        style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.7)),
                  ),
                  const Divider(height: 28),
                  // 파트 목록
                  const Text('강의 파트 목록',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  if (_parts.isEmpty)
                    const Text('등록된 파트가 없습니다',
                        style: TextStyle(fontSize: 12, color: Colors.black45))
                  else
                    ..._parts.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Center(child: Text('${p.orderNo}',
                              style: const TextStyle(fontSize: 10, color: Colors.black54))),
                        ),
                        const SizedBox(width: 10),
                        Text(p.title, style: const TextStyle(fontSize: 12)),
                      ]),
                    )),
                  const Divider(height: 28),
                  // Q&A
                  const Text('질문 (Q&A)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F8F8),
                          border: Border(bottom: BorderSide(color: Colors.black12)),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                        ),
                        child: const Row(
                          children: [Text('질문 목록',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))],
                        ),
                      ),
                      if (_questions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('등록된 질문이 없습니다',
                              style: TextStyle(fontSize: 12, color: Colors.black45)),
                        )
                      else
                        ..._questions.map((q) => InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.questionDetail,
                            arguments: {'questionId': q.questionId, 'lectureId': widget.lectureId},
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))),
                            child: Row(children: [
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(q.title, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(q.createdAt.toString().substring(0, 10),
                                      style: const TextStyle(fontSize: 10, color: Colors.black45)),
                                ],
                              )),
                              const Icon(Icons.chevron_right, size: 16, color: Colors.black26),
                            ]),
                          ),
                        )),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // ── 우측 패널 ──────────────────────────────────────
          SizedBox(
            width: 260,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('수강 신청',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(children: [
                      _InfoRow('파트 수', '${_parts.length}개'),
                      _InfoRow('유형', _typeLabel(lecture.lectureType)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isEnrolled ? null : () => _showEnrollDialog(context, appState),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        side: BorderSide(color: isEnrolled ? Colors.black26 : Colors.black54),
                        backgroundColor: isEnrolled ? Colors.grey.shade100 : Colors.transparent,
                      ),
                      child: Text(
                        isEnrolled ? '수강 중' : '수강 신청',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isEnrolled ? Colors.black45 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (isEnrolled && _parts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context, AppRouter.lectureWatch,
                          arguments: {'lectureId': widget.lectureId, 'partId': _parts.first.partId},
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('강의 시청', style: TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ),
                  ],
                  const Divider(height: 28),
                  const Text('질문 작성',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text('제목', style: TextStyle(fontSize: 10, color: Colors.black45)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleCtrl, maxLength: 100,
                    decoration: InputDecoration(
                      isDense: true, counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text('내용', style: TextStyle(fontSize: 10, color: Colors.black45)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contentCtrl, maxLength: 1000, maxLines: 4,
                    decoration: InputDecoration(
                      isDense: true, counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _submitQuestion(context, appState),
                      child: const Text('질문 등록', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(child: Text('제목 100자 · 내용 1000자',
                      style: TextStyle(fontSize: 10, color: Colors.black45))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'BASIC':   return '기초 학습';
      case 'PROJECT': return '작품 제작';
      case 'PATTERN': return '도안';
      default:        return t;
    }
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
