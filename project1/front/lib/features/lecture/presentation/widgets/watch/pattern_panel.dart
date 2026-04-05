import 'package:flutter/material.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/watch/symbol_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/lecture_pattern.dart';
import '../../../domain/entities/part_pattern.dart';
import '../../../domain/entities/pattern_row.dart';

class PatternPanel extends StatefulWidget {
  const PatternPanel({
    super.key,
    required this.lectureId,
    required this.partId,
    required this.partPatterns,
    required this.lecturePatterns,
    required this.highlightedPattern,
  });

  final int lectureId;
  final int partId;
  final List<PartPattern> partPatterns;
  final List<LecturePattern> lecturePatterns;
  final PartPattern? highlightedPattern;

  @override
  State<PatternPanel> createState() => _PatternPanelState();
}

class _PatternPanelState extends State<PatternPanel> {
  // TSX의 knittingSymbols에 대응하는 기호 목록
  static const List<(String abbr, String name)> _symbols = [
    ('sc', '짧은뜨기'),
    ('inc', '늘림'),
    ('dec', '줄임'),
    ('ch', '사슬뜨기'),
    ('sl st', '빼뜨기'),
    ('dc', '긴뜨기'),
  ];

  int _rowCounter = 0;
  SharedPreferences? _prefs;

  /// SharedPreferences 저장 키 (강의 ID + 파트 ID 조합)
  String get _counterKey =>
      'row_counter_${widget.lectureId}_${widget.partId}';

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  @override
  void didUpdateWidget(PatternPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 파트가 바뀌면 해당 파트의 카운터를 다시 로드
    if (oldWidget.partId != widget.partId ||
        oldWidget.lectureId != widget.lectureId) {
      _loadCounter();
    }
  }

  Future<void> _loadCounter() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _rowCounter = _prefs!.getInt(_counterKey) ?? 0;
      });
    }
  }

  Future<void> _updateCounter(int delta) async {
    final newVal = (_rowCounter + delta).clamp(0, 9999);
    setState(() => _rowCounter = newVal);
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_counterKey, newVal);
  }

  @override
  Widget build(BuildContext context) {
    final List<PatternRow> patterns =
    widget.partPatterns.isNotEmpty
        ? widget.partPatterns
        : widget.lecturePatterns;

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
              children: _symbols
                  .map((e) => SymbolCard(
                abbreviation: e.$1,
                name: e.$2,
              ))
                  .toList(),
            ),

            const SizedBox(height: 20),

            const Text('도안',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...patterns.map((p) {
              final isHighlighted =
                  widget.highlightedPattern?.patternId == p.patternId;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 번호 영역
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${p.rowNum}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 텍스트 영역
                    Expanded(
                      child: Text(
                        p.patternText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
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
            _counterBtn(Icons.remove, () => _updateCounter(-1)),
            SizedBox(
              width: 72,
              child: Center(
                child: Text(
                  '$_rowCounter단',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            _counterBtn(Icons.add, () => _updateCounter(1)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: Colors.black54),
    ),
  );
}