import '../../domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({
    required super.answerId,
    required super.content,
    required super.nickname,
    required super.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
    answerId: json['answerId'] as int,
    content: json['content'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'answerId': answerId,
    'content': content,
    'nickname': nickname,
    'createdAt': createdAt.toIso8601String(),
  };
}
