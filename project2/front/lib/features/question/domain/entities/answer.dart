class Answer {
  final int answerId;
  final int instructorId;
  final String content;
  final String nickname;
  final DateTime createdAt;

  const Answer({
    required this.answerId,
    required this.instructorId,
    required this.content,
    required this.nickname,
    required this.createdAt,
  });
}
