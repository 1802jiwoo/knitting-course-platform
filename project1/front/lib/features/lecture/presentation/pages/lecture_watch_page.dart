import 'package:flutter/material.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/watch/pattern_panel.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
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

class _LectureWatchPageState extends State<LectureWatchPage> with SingleTickerProviderStateMixin {
  final YoutubePlayerController youtubePlayerController = YoutubePlayerController(
    params: const YoutubePlayerParams(
      showControls: true,
      showFullscreenButton: true,
      origin: 'https://www.youtube-nocookie.com',
    ),
  );

  late int _currentPartId;
  late TabController _tabController;
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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _fetchData();
      youtubePlayerController.loadVideoById(videoId: _video!.youtubeUrl);
      youtubePlayerController.stream.listen((event) {
        if (event.playerState == PlayerState.ended) {
          print("영상 끝남!");

          _handlePartCompleted();
        }
      });
    },);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          _parts = results[0] as List<LecturePart>;
          _video = results[1] as Video;
          _partPatterns = results[2] as List<PartPattern>;
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
          _video = results[0] as Video;
          _partPatterns = results[1] as List<PartPattern>;
        });
      }
      print(_video!.youtubeUrl);
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

  bool get _hasPattern => _partPatterns.isNotEmpty || _lecturePatterns.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completedParts = appState.completedPartsFor(widget.lectureId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          const Text('LoopLearn',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
        // ── 좌측: 비디오 + 정보 (70%) ──────────────────────────────
        Expanded(
          child: Column(children: [
            // 비디오 영역
            Expanded(
              child: Container(
                color: Colors.black,
                child: YoutubePlayer(
                  controller: youtubePlayerController,

                ),
              ),
            ),

            // 비디오 정보 바 (TSX: Video Info)
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
                      '파트 ${_currentPart?.orderNo ?? '-'}. ${_currentPart?.title ?? ''}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '파트 ${_currentPart?.orderNo ?? '-'} / ${_parts.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                )),
                if (completedParts.contains(_currentPartId))
                  const Row(children: [
                    Icon(Icons.check_circle_outline, size: 14, color: Colors.black45),
                    SizedBox(width: 4),
                    Text('시청 완료',
                        style: TextStyle(fontSize: 11, color: Colors.black45)),
                  ]),
              ]),
            ),
          ]),
        ),

        // ── 우측: 탭 패널 (고정 280px) ──────────────────────────────
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Column(children: [
            // 탭 헤더 (TSX: TabsList)
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: AppColors.primary),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: const [
                  Tab(text: '강의 목록'),
                  Tab(text: '도안'),
                ],
              ),
            ),

            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── 강의 목록 탭 ──
                  _PartListPanel(
                    parts: _parts,
                    currentPartId: _currentPartId,
                    completedParts: completedParts,
                    onPartSelected: _selectPart,
                    onQnaTap: () {
                      // TODO: Q&A 페이지로 이동
                    },
                  ),

                  // ── 도안 탭 ──
                  _hasPattern
                      ? PatternPanel(
                    partPatterns: _partPatterns,
                    lecturePatterns: _lecturePatterns,
                    highlightedPattern: _highlightedPattern,
                    rowCounter: _rowCounter,
                    onCounterChange: (d) => setState(
                            () => _rowCounter = (_rowCounter + d).clamp(0, 9999)),
                  )
                      : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('이 강의에는 도안이 제공되지 않습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: Colors.black45)),
                    ),
                  ),
                ],
              ),
            ),
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

// ════════════════════════════════════════════════════════════════
// 강의 목록 패널 (TSX: TabsContent value="lectures")
// ════════════════════════════════════════════════════════════════
class _PartListPanel extends StatelessWidget {
  final List<LecturePart> parts;
  final int currentPartId;
  final Set<int> completedParts;
  final ValueChanged<int> onPartSelected;
  final VoidCallback onQnaTap;

  const _PartListPanel({
    required this.parts,
    required this.currentPartId,
    required this.completedParts,
    required this.onPartSelected,
    required this.onQnaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
                    color: isCurrent ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: isCurrent ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  // 번호 뱃지 (TSX: w-8 h-8 rounded-lg)
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      // TSX: bg-primary text-primary-foreground when completed
                      color: isCompleted
                          ? AppColors.primary
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text('${p.orderNo}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 제목 + 시간
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      // Text(
                      //   _formatDuration(p.durationSec),
                      //   style: const TextStyle(fontSize: 11, color: Colors.black45),
                      // ),
                    ],
                  )),
                  // 현재 파트 화살표 (TSX: ChevronRight)
                  if (isCurrent)
                    Icon(Icons.chevron_right, size: 20, color: AppColors.primary),
                ]),
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
                  borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    ]);
  }

  String _formatDuration(int? sec) {
    if (sec == null) return '';
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ════════════════════════════════════════════════════════════════
// 카운터 버튼 (TSX: −/+ 버튼)
// ════════════════════════════════════════════════════════════════
class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}