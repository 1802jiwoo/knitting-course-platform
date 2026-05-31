import '../../domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.videoId,
    required super.partId,
    required super.youtubeUrl,
    required super.duration,
  });

  factory VideoModel.fromJson(
    Map<String, dynamic> json, {
    required int partId,
  }) => VideoModel(
    videoId: json['videoId'] as int,
    partId: partId,
    youtubeUrl: json['youtubeUrl'] as String,
    duration: json['duration'] as int,
  );

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'youtubeUrl': youtubeUrl,
    'duration': duration,
  };
}
