import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:loop_learn/core/theme/app_colors.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/detail/lecture_detail_curriculum.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/detail/lecture_detail_left.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/detail/lecture_detail_right.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/detail/lecture_detail_thumbnail.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/lecture_nav_bar.dart';
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

  // List<Question> _questions = [];
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lectureRepo = context.read<LectureRepository>();
      // final questionRepo = context.read<QuestionRepository>();
      final results = await Future.wait([
        lectureRepo.getLectureDetail(widget.lectureId),
        lectureRepo.getLectureParts(widget.lectureId),
        // questionRepo.getQuestions(widget.lectureId),
      ]);
      if (mounted) {
        setState(() {
          _lecture = results[0] as Lecture;
          _parts = results[1] as List<LecturePart>;
          // _questions = results[2] as List<Question>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = '강의 정보를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  // Future<void> _submitQuestion(BuildContext context, AppState appState) async {
  //   final title = _titleCtrl.text.trim();
  //   final content = _contentCtrl.text.trim();
  //   if (title.isEmpty || content.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('필수 항목을 입력해 주세요')));
  //     return;
  //   }
  //   try {
  //     final repo = context.read<QuestionRepository>();
  //     await repo.postQuestion(
  //       lectureId: widget.lectureId,
  //       title: title,
  //       content: content,
  //     );
  //     _titleCtrl.clear();
  //     _contentCtrl.clear();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('질문이 등록되었습니다')));
  //     // 질문 목록 새로고침
  //     final newQs = await repo.getQuestions(widget.lectureId);
  //     if (mounted) setState(() => _questions = newQs);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('질문 등록에 실패했습니다.')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(
      appBar: LoopLearnNavBar(currentRoute: AppRouter.lectureList),
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: const TextStyle(color: Colors.black45)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _fetchAll, child: const Text('다시 시도')),
      ])),
    );

    final lecture = _lecture!;

    // API LectureModel의 tagNames 추출
    final tagNames = (lecture as dynamic).tagNames as List<String>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LectureNavBar(
        currentRoute: AppRouter.lectureList,
      ),
      body: context.isTablet ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LectureDetailLeft(
            lecture: _lecture!, lectureId: widget.lectureId, parts: _parts,
          ),
          LectureDetailRight(
            lecture: _lecture!, lectureId: widget.lectureId, parts: _parts,
          ),
        ],
      ) : SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LectureDetailLeft(
                lecture: _lecture!, lectureId: widget.lectureId, parts: _parts,
              ),
              LectureDetailRight(
                lecture: _lecture!, lectureId: widget.lectureId, parts: _parts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


