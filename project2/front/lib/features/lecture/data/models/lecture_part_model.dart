import '../../domain/entities/lecture_part.dart';

class LecturePartModel extends LecturePart {
  const LecturePartModel({
    required super.partId,
    required super.lectureId,
    required super.title,
    required super.orderNo,
  });

  factory LecturePartModel.fromJson(
    Map<String, dynamic> json, {
    required int lectureId,
  }) => LecturePartModel(
    partId: json['partId'] as int,
    lectureId: lectureId,
    title: json['title'] as String,
    orderNo: json['order'] as int,
  );

  Map<String, dynamic> toJson() => {
    'partId': partId,
    'title': title,
    'order': orderNo,
  };
}
