import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/answer.dart';
import '../../domain/repositories/answer_repository.dart';
import '../models/answer_model.dart';

class AnswerRepositoryImpl implements AnswerRepository {
  final ApiClient api;

  AnswerRepositoryImpl({required this.api});

  @override
  Future<Answer?> getAnswer(int questionId) async {
    try {
      final response = await api.get('/api/questions/$questionId/answer');
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return AnswerModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
