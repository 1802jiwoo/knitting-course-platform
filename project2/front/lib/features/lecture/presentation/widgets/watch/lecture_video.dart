import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:loop_learn/features/lecture/domain/entities/lecture_part.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LectureVideo extends StatefulWidget {
  const LectureVideo({super.key, required this.controller, required this.currentPart, required this.partLength, required this.isCompleted});
  
  final YoutubePlayerController controller;
  final LecturePart? currentPart;
  final int partLength;
  final bool isCompleted;

  @override
  State<LectureVideo> createState() => _LectureVideoState();
}

class _LectureVideoState extends State<LectureVideo> {
  @override
  Widget build(BuildContext context) {
    return context.isTablet ? Expanded(
      child: content(),
    ) : content();
  }

  Widget content() => Column(children: [
    // 비디오 영역
    context.isTablet ? Expanded(
      child: Container(
        color: Colors.black,
        child: YoutubePlayer(
          controller: widget.controller,
        ),
      ),
    ) : Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).width * 0.5,
      color: Colors.black,
      child: YoutubePlayer(
        controller: widget.controller,
      ),
    ),

    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '파트 ${widget.currentPart?.orderNo ?? '-'}. ${widget.currentPart?.title ?? ''}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '파트 ${widget.currentPart?.orderNo ?? '-'} / ${widget.partLength}',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        )),
        if (widget.isCompleted)
          const Row(children: [
            Icon(Icons.check_circle_outline, size: 14, color: Colors.black45),
            SizedBox(width: 4),
            Text('시청 완료',
                style: TextStyle(fontSize: 11, color: Colors.black45)),
          ]),
      ]),
    ),
  ]);
}
