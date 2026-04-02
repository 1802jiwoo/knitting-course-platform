import 'package:flutter/material.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/watch/symbol_card.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/lecture_pattern.dart';
import '../../../domain/entities/part_pattern.dart';
import '../../../domain/entities/pattern_row.dart';

class PatternPanel extends StatelessWidget {
  const PatternPanel({
    super.key,
    required this.partPatterns,
    required this.lecturePatterns,
    required this.highlightedPattern,
    required this.rowCounter,
    required this.onCounterChange,
  });

  final List<PartPattern> partPatterns;
  final List<LecturePattern> lecturePatterns;
  final PartPattern? highlightedPattern;
  final int rowCounter;
  final ValueChanged<int> onCounterChange;
  // TSX의 knittingSymbols에 대응하는 기호 목록
  static const List<(String abbr, String name)> _symbols = [
    ('sc',    '짧은뜨기'),
    ('inc',   '늘림'),
    ('dec',   '줄임'),
    ('ch',    '사슬뜨기'),
    ('sl st', '빼뜨기'),
    ('dc',    '긴뜨기'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<PatternRow> patterns =
    partPatterns.isNotEmpty ? partPatterns : lecturePatterns;

    return Column(children: [
      // 스크롤 영역
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ── 기호 설명 그리드 (TSX: grid grid-cols-2) ──
            const Text('기호 설명',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 2.4,
              children: _symbols.map((e) => SymbolCard(
                abbreviation: e.$1,
                name: e.$2,
              )).toList(),
            ),

            const SizedBox(height: 20),

            const Text('도안',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...patterns.map((p) {
              final isHighlighted = highlightedPattern?.patternId == p.patternId;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.primary.withOpacity(0.6)
                        : const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  // 행 번호 뱃지 (TSX: w-8 h-8 rounded-lg bg-primary/10)
                  Container(
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(7)),
                    ),
                    child: Center(
                      child: Text('${p.rowNum}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ),
                  ),
                  // 도안 내용
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Text(
                      p.patternText,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: isHighlighted
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isHighlighted
                              ? Colors.black87
                              : Colors.black54),
                    ),
                  )),
                ]),
              );
            }),
          ],
        ),
      ),

      // ── 단수 카운터 (TSX: RowCounter 하단 고정) ──
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Column(children: [
          const Text('단수 카운터',
              style: TextStyle(fontSize: 11, color: Colors.black45)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            counterBtn(
              Icons.remove, () => onCounterChange(-1),
            ),
            SizedBox(
              width: 72,
              child: Center(
                child: Text('${rowCounter}단',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            counterBtn(
              Icons.add, () => onCounterChange(1),
            ),
          ]),
        ]),
      ),
    ]);
  }

  Widget counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: Colors.black54),
    ),
  );
}