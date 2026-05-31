import '../../domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({
    required super.answerId,
    required super.instructorId,
    required super.content,
    required super.nickname,
    required super.createdAt,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
    answerId: (json['answerId'] as num).toInt(),
    instructorId: (json['instructorId'] as num).toInt(),
    content: json['content'] as String,
    nickname: json['nickname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
