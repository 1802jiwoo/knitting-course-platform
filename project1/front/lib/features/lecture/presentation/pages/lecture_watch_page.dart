import 'package:flutter/material.dart';
import 'package:loop_learn/core/extensions/context_extension.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/watch/lecture_video.dart';
import 'package:loop_learn/features/lecture/presentation/widgets/watch/pattern_panel.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/lecture/domain/entities/lecture_part.dart';
import '../../../../features/lecture/domain/entities/part_pattern.dart';
import '../../../../features/lecture/domain/entities/lecture_pattern.dart';
import '../../../../features/lecture/domain/entities/pattern_row.dart';
import '../../../../features/lecture/domain/entities/video.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../widgets/lecture_nav_bar.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/watch/part_list_panel.dart';

class LectureWatchPage extends StatefulWidget {
  final int lectureId;
  final int partId;

  const LectureWatchPage({
    super.key,
    required this.lectureId,
    required this.partId,
  });

  @override
  State<LectureWatchPage> createState() => _LectureWatchPageState();
}

class _LectureWatchPageState extends State<LectureWatchPage>
    with SingleTickerProviderStateMixin {
  final YoutubePlayerController youtubePlayerController =
      YoutubePlayerController(
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
          _handlePartCompleted();
        }
      });
    });
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
    } catch (_) {}
  }

  LecturePart? get _currentPart {
    try {
      return _parts.firstWhere((p) => p.partId == _currentPartId);
    } catch (_) {
      return null;
    }
  }

  PartPattern? get _highlightedPattern {
    for (final p in _partPatterns) {
      if (_dummyCurrentSec >= p.startTime && _dummyCurrentSec < p.endTime)
        return p;
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

  void _handlePartCompleted() {
    final appState = context.read<AppState>();
    if (appState.completedPartsFor(widget.lectureId).contains(_currentPartId))
      return;
    appState.completePart(widget.lectureId, _currentPartId);

    final idx = _parts.indexWhere((p) => p.partId == _currentPartId);
    final isLast = idx == _parts.length - 1;

    if (isLast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 파트를 완료했습니다!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_currentPart?.title} 완료! 다음 파트로 이동합니다.'),
          duration: const Duration(seconds: 1),
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _selectPart(_parts[idx + 1].partId);
      });
    }
  }

  bool get _hasPattern =>
      _partPatterns.isNotEmpty || _lecturePatterns.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final completedParts = appState.completedPartsFor(widget.lectureId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: LectureNavBar(currentRoute: AppRouter.lectureWatch),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : context.isTablet
          ? Row(
              children: [
                LectureVideo(
                  controller: youtubePlayerController,
                  currentPart: _currentPart,
                  partLength: _parts.length,
                  isCompleted: completedParts.contains(_currentPartId),
                ),

                rightPanel(completedParts),
              ],
            )
          : Column(
              children: [
                LectureVideo(
                  controller: youtubePlayerController,
                  currentPart: _currentPart,
                  partLength: _parts.length,
                  isCompleted: completedParts.contains(_currentPartId),
                ),

                rightPanel(completedParts),
              ],
            ),
    );
  }

  Widget rightPanel(Set<int> completedParts) => Expanded(
    child: Container(
      width: context.isTablet ? 280 : double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
                PartListPanel(
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
                          () => _rowCounter = (_rowCounter + d).clamp(0, 9999),
                        ),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '이 강의에는 도안이 제공되지 않습니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black45),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
