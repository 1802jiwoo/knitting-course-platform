class Question {
  final int questionId;
  final int userId;
  final int lectureId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const Question({
    required this.questionId,
    required this.userId,
    required this.lectureId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
}
