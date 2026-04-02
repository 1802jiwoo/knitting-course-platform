import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';

class LectureDetailThumbnail extends StatelessWidget {
  const LectureDetailThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
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
        // lecture.thumbnailUrl,
        'https://www.hanbit.co.kr/data/editor/20181219134720_zbkqflmi.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Center(
          child: Icon(Icons.image_not_supported, color: Colors.black26),
        ),
      ),
    );
  }
}
