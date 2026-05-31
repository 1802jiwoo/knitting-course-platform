import '../../../../core/network/api_client.dart';
import '../../domain/entities/answer.dart';
import '../../domain/repositories/answer_repository.dart';
import '../models/answer_model.dart';

class AnswerRepositoryImpl implements AnswerRepository {
  final ApiClient api;

  AnswerRepositoryImpl({required this.api});

  @override
  Future<List<Answer>> getAnswers(int questionId) async {
    try {
      final data = await api.get('/questions/$questionId/answer') as List<dynamic>;
      return data.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Answer> createAnswer(int questionId, String content) async {
    final data = await api.post(
      '/questions/$questionId/answer',
      body: {'content': content},
    ) as Map<String, dynamic>;
    return AnswerModel.fromJson(data);
  }

  @override
  Future<Answer> updateAnswer(int answerId, String content) async {
    final data = await api.patch(
      '/answers/$answerId',
      body: {'content': content},
    ) as Map<String, dynamic>;
    return AnswerModel.fromJson(data);
  }

  @override
  Future<void> deleteAnswer(int answerId) async {
    await api.delete('/answers/$answerId');
  }
}
