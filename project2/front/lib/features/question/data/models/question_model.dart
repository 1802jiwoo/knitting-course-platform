import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.questionId,
    required super.nickname,
    required super.lectureId,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.createdAt,
  });

  factory QuestionModel.fromListJson(
    Map<String, dynamic> json, {
    required int lectureId,
  }) => QuestionModel(
    questionId: json['questionId'] as int,
    nickname: json['nickname'] as String,
    lectureId: lectureId,
    title: json['title'] as String,
    content: '',
    imageUrl: json['imageUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  factory QuestionModel.fromDetailJson(Map<String, dynamic> json) =>
      QuestionModel(
        questionId: json['questionId'] as int,
        nickname: json['nickname'] as String,
        lectureId: json['lectureId'] as int,
        title: json['title'] as String,
        content: json['content'] as String,
        imageUrl: json['imageUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'lectureId': lectureId,
    'title': title,
    'content': content,
  };
}
