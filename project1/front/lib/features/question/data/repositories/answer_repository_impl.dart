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
      final data = await api.get('/questions/$questionId/answer') as Map<String, dynamic>;
      print(data);
      return AnswerModel.fromJson(data);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
