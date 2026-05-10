import '../../domain/entities/instructor_part.dart';

class InstructorPartModel extends InstructorPart {
  const InstructorPartModel({
    required super.partId,
    required super.lectureId,
    required super.title,
    super.youtubeUrl,
    super.duration,
    required super.orderNo,
  });

  factory InstructorPartModel.fromJson(
    Map<String, dynamic> json, {
    required int lectureId,
  }) =>
      InstructorPartModel(
        partId: (json['partId'] as num).toInt(),
        lectureId: lectureId,
        title: json['title'] as String,
        youtubeUrl: json['youtubeUrl'] as String?,
        duration: json['duration'] != null
            ? (json['duration'] as num).toInt()
            : null,
        orderNo: (json['order'] as num).toInt(),
      );
}
