class InstructorPart {
  final int partId;
  final int lectureId;
  final String title;
  final String? youtubeUrl;
  final int? duration;
  final int orderNo;

  const InstructorPart({
    required this.partId,
    required this.lectureId,
    required this.title,
    this.youtubeUrl,
    this.duration,
    required this.orderNo,
  });
}
