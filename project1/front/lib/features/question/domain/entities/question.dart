class Question {
  final int questionId;
  final String nickname;
  final int lectureId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const Question({
    required this.questionId,
    required this.nickname,
    required this.lectureId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
}
