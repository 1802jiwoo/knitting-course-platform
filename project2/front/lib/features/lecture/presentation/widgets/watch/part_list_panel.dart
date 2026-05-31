import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/lecture_part.dart';

class PartListPanel extends StatelessWidget {
  final List<LecturePart> parts;
  final int currentPartId;
  final Set<int> completedParts;
  final ValueChanged<int> onPartSelected;
  final VoidCallback onQnaTap;

  const PartListPanel({
    super.key,
    required this.parts,
    required this.currentPartId,
    required this.completedParts,
    required this.onPartSelected,
    required this.onQnaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 파트 목록 스크롤 영역
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: parts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final p = parts[i];
              final isCurrent = p.partId == currentPartId;
              final isCompleted = completedParts.contains(p.partId);

              return GestureDetector(
                onTap: () => onPartSelected(p.partId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // TSX: border-primary bg-primary/5 when active
                    color: isCurrent
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.white,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 번호 뱃지 (TSX: w-8 h-8 rounded-lg)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          // TSX: bg-primary text-primary-foreground when completed
                          color: isCompleted
                              ? AppColors.primary
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                              : Text(
                            '${p.orderNo}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 제목 + 시간
                      Expanded(
                        child: Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 현재 파트 화살표 (TSX: ChevronRight)
                      if (isCurrent)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Q&A 버튼 (TSX: 하단 고정)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQnaTap,
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('질문하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int? sec) {
    if (sec == null) return '';
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
