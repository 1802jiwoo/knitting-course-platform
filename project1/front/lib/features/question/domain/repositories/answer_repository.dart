import '../entities/answer.dart';

abstract class AnswerRepository {
  Future<Answer?> getAnswer(int questionId);
}