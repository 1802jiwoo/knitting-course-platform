import '../entities/answer.dart';

abstract class AnswerRepository {
  Future<List<Answer>> getAnswers(int questionId);
  Future<Answer> createAnswer(int questionId, String content);
  Future<Answer> updateAnswer(int answerId, String content);
  Future<void> deleteAnswer(int answerId);
}
