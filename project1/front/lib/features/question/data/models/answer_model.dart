import '../../domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({
    required super.answerId,
    required super.content,
    required super.nickname,
    required super.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
    answerId: json['answer_id'] as int,
    content: json['content'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'answer_id': answerId,
    'content': content,
    'nickname': nickname,
    'created_at': createdAt.toIso8601String(),
  };
}
