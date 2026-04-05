import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';

class LectureDetailThumbnail extends StatelessWidget {
  const LectureDetailThumbnail({super.key, required this.lectureType});

  final String lectureType;

  @override
  Widget build(BuildContext context) {

    String _getImage() {
      switch (lectureType) {
        case 'BASIC': return 'https://i.pinimg.com/736x/0d/eb/d8/0debd8a1fdfb48ae02d597c13d5d5e7d.jpg';
        case 'PROJECT': return 'https://i.pinimg.com/736x/93/10/e4/9310e46a0d10bb95d76cb4866c5742d6.jpg';
        case 'PATTERN': return 'https://i.pinimg.com/736x/1e/41/cf/1e41cfebfc77d2e2372a270ebcd3844a.jpg';
        default: return '';
      }
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.infinity,
      height: context.isTablet ? 500 : MediaQuery.sizeOf(context).height - 450,
      // 16:9 비율
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.network(
        _getImage(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Center(
          child: Icon(Icons.image_not_supported, color: Colors.black26),
        ),
      ),
    );
  }
}
