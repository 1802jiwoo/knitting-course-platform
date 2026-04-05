import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';
import '../../../../core/network/api_client.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final ApiClient _api;

  QuestionRepositoryImpl({required ApiClient api}) : _api = api;

  // 질문 가져오기
  @override
  Future<List<Question>> getQuestions(int lectureId) async {
    final data =
        await _api.get('/lectures/$lectureId/questions') as List<dynamic>;

    return data
        .map(
          (e) => QuestionModel.fromListJson(
            e as Map<String, dynamic>,
            lectureId: lectureId,
          ),
        )
        .toList();
  }

  // 질문 상세
  @override
  Future<Question> getQuestionDetail(int questionId) async {
    final data =
        await _api.get('/questions/$questionId') as Map<String, dynamic>;
    return QuestionModel.fromDetailJson(data);
  }

  // 질문 하기
  @override
  Future<void> postQuestion({
    required int lectureId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    await _api.post(
      '/questions',
      body: {'lectureId': lectureId, 'title': title, 'content': content},
    );
  }
}
