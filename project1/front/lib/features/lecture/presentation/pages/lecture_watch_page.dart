import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture_part.dart';
import '../../../../features/lecture/domain/entities/part_pattern.dart';
import '../../../../features/lecture/domain/entities/lecture_pattern.dart';
import '../../../../features/lecture/domain/entities/pattern_row.dart';
import '../../../../features/lecture/domain/entities/video.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../widgets/shared_widgets.dart';

class LectureWatchPage extends StatefulWidget {
  final int lectureId;
  final int partId;

  const LectureWatchPage({super.key, required this.lectureId, required this.partId});

  @override
  State<LectureWatchPage> createState() => _LectureWatchPageState();
}

class _LectureWatchPageState extends State<LectureWatchPage> {
  late int _currentPartId;
  bool _showPatternPanel = true;
  int _rowCounter = 0;
  int _dummyCurrentSec = 0;

  // API 상태
  List<LecturePart> _parts = [];
  Video? _video;
  List<PartPattern> _partPatterns = [];
  List<LecturePattern> _lecturePatterns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPartId = widget.partId;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<LectureRepository>();
      final results = await Future.wait([
        repo.getLectureParts(widget.lectureId),
        repo.getPartVideo(_currentPartId),
        repo.getPartPatterns(_currentPartId),
        repo.getLecturePatterns(widget.lectureId),
      ]);
      if (mounted) {
        setState(() {
          _parts          = results[0] as List<LecturePart>;
          _video          = results[1] as Video;
          _partPatterns   = results[2] as List<PartPattern>;
          _lecturePatterns = results[3] as List<LecturePattern>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPartData(int partId) async {
    try {
      final repo = context.read<LectureRepository>();
      final results = await Future.wait([
        repo.getPartVideo(partId),
        repo.getPartPatterns(partId),
      ]);
      if (mounted) {
        setState(() {
          _video        = results[0] as Video;
          _partPatterns = results[1] as List<PartPattern>;
        });
      }
    } catch (_) {}
  }

  LecturePart? get _currentPart {
    try { return _parts.firstWhere((p) => p.partId == _currentPartId); }
    catch (_) { return null; }
  }

  int get _maxSec {
    final raw = _video?.duration ?? 300;
    return raw > 300 ? 300 : raw;
  }

  PartPattern? get _highlightedPattern {
    for (final p in _partPatterns) {
      if (_dummyCurrentSec >= p.startTime && _dummyCurrentSec < p.endTime) return p;
    }
    return null;
  }

  void _selectPart(int partId) {
    setState(() {
      _currentPartId = partId;
      _dummyCurrentSec = 0;
    });
    _fetchPartData(partId);
  }

  void _onSliderEnd(double value) {
    if (value.round() >= _maxSec) _handlePartCompleted();
  }

  void _handlePartCompleted() {
    final appState = context.read<AppState>();
    if (appState.completedPartsFor(widget.lectureId).contains(_currentPartId)) return;
    appState.completePart(widget.lectureId, _currentPartId);

    final idx = _parts.indexWhere((p) => p.partId == _currentPartId);
    final isLast = idx == _parts.length - 1;

    if (isLast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 파트를 완료했습니다!'), duration: Duration(seconds: 2)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_currentPart?.title} 완료! 다음 파트로 이동합니다.'),
            duration: const Duration(seconds: 1)));
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _selectPart(_parts[idx + 1].partId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completedParts = appState.completedPartsFor(widget.lectureId);
    final hasPartPattern = _partPatterns.isNotEmpty;
    final hasLecturePattern = _lecturePatterns.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, titleSpacing: 12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Text('LoopLearn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Text(' › ', style: TextStyle(fontSize: 11, color: Colors.black45)),
          Flexible(child: Text(
            _currentPart?.title ?? '',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          )),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black.withOpacity(0.1)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              Expanded(child: Column(children: [
                Expanded(child: Container(
                  color: Colors.grey.shade100,
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.play_circle_outline, size: 72, color: Colors.black26),
                    Positioned(
                      bottom: 12, left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('YouTube 영상 영역',
                            style: TextStyle(fontSize: 10, color: Colors.black45)),
                      ),
                    ),
                  ]),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    Text(_formatTime(_dummyCurrentSec),
                        style: const TextStyle(fontSize: 10, color: Colors.black45)),
                    Expanded(child: Slider(
                      value: _dummyCurrentSec.toDouble().clamp(0, _maxSec.toDouble()),
                      min: 0, max: _maxSec.toDouble(),
                      activeColor: Colors.black54, inactiveColor: Colors.black12,
                      onChanged: (v) => setState(() => _dummyCurrentSec = v.round()),
                      onChangeEnd: _onSliderEnd,
                    )),
                    Text(_formatTime(_maxSec),
                        style: const TextStyle(fontSize: 10, color: Colors.black45)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_currentPart?.title ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('파트 ${_currentPart?.orderNo ?? '-'} / ${_parts.length}',
                          style: const TextStyle(fontSize: 11, color: Colors.black45)),
                    ]),
                    const Spacer(),
                    if (completedParts.contains(_currentPartId))
                      const Row(children: [
                        Icon(Icons.check_circle_outline, size: 14, color: Colors.black45),
                        SizedBox(width: 4),
                        Text('시청 완료', style: TextStyle(fontSize: 11, color: Colors.black45)),
                      ]),
                  ]),
                ),
              ])),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 280,
                child: Column(children: [
                  Row(children: [
                    Expanded(child: _PanelTab(
                      label: '강의 목록',
                      isActive: !_showPatternPanel,
                      onTap: () => setState(() => _showPatternPanel = false),
                    )),
                    if (hasPartPattern || hasLecturePattern)
                      Expanded(child: _PanelTab(
                        label: '도안 보기',
                        isActive: _showPatternPanel,
                        onTap: () => setState(() => _showPatternPanel = true),
                      )),
                  ]),
                  const Divider(height: 1),
                  Expanded(child: _showPatternPanel && (hasPartPattern || hasLecturePattern)
                      ? _PatternPanel(
                          partPatterns: _partPatterns,
                          lecturePatterns: _lecturePatterns,
                          highlightedPattern: _highlightedPattern,
                          rowCounter: _rowCounter,
                          onCounterChange: (d) => setState(
                              () => _rowCounter = (_rowCounter + d).clamp(0, 9999)),
                        )
                      : _PartListPanel(
                          parts: _parts,
                          currentPartId: _currentPartId,
                          onPartSelected: _selectPart,
                        )),
                ]),
              ),
            ]),
    );
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _PanelTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PanelTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(
            color: isActive ? Colors.black87 : Colors.transparent, width: 2))),
        child: Center(child: Text(label, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isActive ? Colors.black87 : Colors.black38))),
      ),
    );
  }
}

class _PartListPanel extends StatelessWidget {
  final List<LecturePart> parts;
  final int currentPartId;
  final ValueChanged<int> onPartSelected;
  const _PartListPanel({required this.parts, required this.currentPartId, required this.onPartSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(11),
      children: parts.map((p) => GestureDetector(
        onTap: () => onPartSelected(p.partId),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: p.partId == currentPartId ? Colors.grey.shade100 : Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black26)),
              child: Center(child: Text('${p.orderNo}',
                  style: const TextStyle(fontSize: 10, color: Colors.black54))),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(p.title, style: const TextStyle(fontSize: 12))),
            if (p.partId == currentPartId)
              Container(width: 7, height: 7,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87)),
          ]),
        ),
      )).toList(),
    );
  }
}

class _PatternPanel extends StatelessWidget {
  final List<PartPattern> partPatterns;
  final List<LecturePattern> lecturePatterns;
  final PartPattern? highlightedPattern;
  final int rowCounter;
  final ValueChanged<int> onCounterChange;

  const _PatternPanel({
    required this.partPatterns,
    required this.lecturePatterns,
    required this.highlightedPattern,
    required this.rowCounter,
    required this.onCounterChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<PatternRow> patterns =
        partPatterns.isNotEmpty ? partPatterns : lecturePatterns;

    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('도안', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            if (partPatterns.isNotEmpty)
              const Text('재생 시간 기준 자동 표시',
                  style: TextStyle(fontSize: 10, color: Colors.black45)),
          ]),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(11), children: [
        ...patterns.map((p) {
          final isHighlighted = highlightedPattern?.patternId == p.patternId;
          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border.all(color: isHighlighted ? Colors.black54 : Colors.black12),
              borderRadius: BorderRadius.circular(6),
              color: isHighlighted ? Colors.grey.shade50 : Colors.white,
            ),
            child: Row(children: [
              Container(
                width: 32, padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.black87 : Colors.grey.shade100,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                  border: const Border(right: BorderSide(color: Colors.black12)),
                ),
                child: Center(child: Text('${p.rowNum}단',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                        color: isHighlighted ? Colors.white : Colors.black45))),
              ),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                child: Text(p.patternText, style: TextStyle(
                    fontSize: 11,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                    color: isHighlighted ? Colors.black87 : Colors.black54)),
              )),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(6)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('기호 범례', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black45)),
            const SizedBox(height: 5),
            ...const [('sc','짧은뜨기'),('inc','늘림'),('dec','줄임'),('ch','사슬뜨기'),('sl st','빼뜨기')]
                .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(children: [
                    SizedBox(width: 36, child: Text(e.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    Text(e.$2, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ]),
                )),
          ]),
        ),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
        child: Column(children: [
          const Text('단수 카운터', style: TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _CounterBtn(icon: '−', onTap: () => onCounterChange(-1)),
            SizedBox(width: 60, child: Center(child: Text('${rowCounter}단',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            _CounterBtn(icon: '+', onTap: () => onCounterChange(1)),
          ]),
        ]),
      ),
    ]);
  }
}

class _CounterBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(6)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 16, color: Colors.black54))),
      ),
    );
  }
}
