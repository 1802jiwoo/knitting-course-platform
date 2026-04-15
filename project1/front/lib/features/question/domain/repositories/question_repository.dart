import 'package:image_picker/image_picker.dart';

import '../entities/question.dart';

abstract class QuestionRepository {
  Future<List<Question>> getQuestions(int lectureId);

  Future<Question> getQuestionDetail(int questionId);

  Future<void> postQuestion({
    required int lectureId,
    required String title,
    required String content,
    XFile? image,
  });
}
