import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';

class LectureDetailThumbnail extends StatelessWidget {
  const LectureDetailThumbnail({
    super.key,
    required this.lectureType,
    this.thumbnailUrl,
  });

  final String lectureType;
  final String? thumbnailUrl;

  static const _fallbackImages = {
    'STITCH_BASICS': 'https://i.pinimg.com/736x/8c/5b/26/8c5b2668a5e97e3d7e7ef615c2958a72.jpg',
    'PROJECT_CLASS': 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg',
    'PATTERN': 'https://i.pinimg.com/736x/1e/41/cf/1e41cfebfc77d2e2372a270ebcd3844a.jpg',
  };

  String get _imageUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl!;
    return _fallbackImages[lectureType] ?? _fallbackImages['PROJECT_CLASS']!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      height: context.isTablet ? 500 : MediaQuery.sizeOf(context).height - 450,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.network(
        _imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported, color: Colors.black26),
        ),
      ),
    );
  }
}
