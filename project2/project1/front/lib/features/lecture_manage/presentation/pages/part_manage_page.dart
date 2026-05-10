import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../../../core/router/app_router.dart';
import '../../domain/entities/instructor_part.dart';
import '../providers/part_manage_state.dart';

class PartManagePage extends StatefulWidget {
  final int lectureId;
  final String lectureTitle;

  const PartManagePage({
    super.key,
    required this.lectureId,
    required this.lectureTitle,
  });

  @override
  State<PartManagePage> createState() => _PartManagePageState();
}

class _PartManagePageState extends State<PartManagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartManageState>().loadParts(widget.lectureId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PartManageState>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('파트 관리'),
            Text(
              widget.lectureTitle,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPartDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('파트 추가'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PartManageState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                state.clearError();
                state.loadParts(widget.lectureId);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.parts.isEmpty) {
      return const Center(
        child: Text(
          '등록된 파트가 없습니다.\n파트를 추가해 주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.parts.length,
      onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, state),
      itemBuilder: (context, index) {
        final part = state.parts[index];
        return _PartTile(
          key: ValueKey(part.partId),
          part: part,
          index: index,
          onEdit: () => _showPartDialog(context, part: part),
          onDelete: () => _confirmDelete(context, part),
          onManagePattern: () => Navigator.pushNamed(
            context,
            AppRouter.partPatternManage,
            arguments: {
              'partId': part.partId,
              'partTitle': part.title,
            },
          ),
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex, PartManageState state) {
    state.reorderLocal(oldIndex, newIndex);
    final partIds = state.parts.map((p) => p.partId).toList();
    state.reorderParts(lectureId: widget.lectureId, partIds: partIds);
  }

  void _showPartDialog(BuildContext context, {InstructorPart? part}) {
    showDialog(
      context: context,
      builder: (_) => _PartFormDialog(
        lectureId: widget.lectureId,
        existing: part,
      ),
    );
  }

  void _confirmDelete(BuildContext context, InstructorPart part) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('파트 삭제', style: TextStyle(fontSize: 16)),
        content: Text('"${part.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<PartManageState>().deletePart(
                    partId: part.partId,
                    lectureId: widget.lectureId,
                  );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<PartManageState>().error ?? '삭제에 실패했습니다.',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// ── 파트 타일 ──────────────────────────────────────────────────────────────

class _PartTile extends StatelessWidget {
  final InstructorPart part;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManagePattern;

  const _PartTile({
    super.key,
    required this.part,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onManagePattern,
  });

  String get _durationText {
    final d = part.duration;
    if (d == null || d == 0) return '0분';
    final m = d ~/ 60;
    final s = d % 60;
    return s > 0 ? '$m분 $s초' : '$m분';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.black26, size: 20),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        title: Text(
          part.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              if (part.youtubeUrl != null && part.youtubeUrl!.isNotEmpty) ...[
                const Icon(Icons.play_circle_outline,
                    size: 13, color: Colors.black38),
                const SizedBox(width: 3),
                const Text('YouTube',
                    style: TextStyle(fontSize: 11, color: Colors.black38)),
                const Text(' · ',
                    style: TextStyle(fontSize: 11, color: Colors.black26)),
              ],
              Text(
                _durationText,
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.grid_on_outlined, size: 18),
              onPressed: onManagePattern,
              tooltip: '도안 관리',
              color: Colors.black45,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
              tooltip: '수정',
              color: Colors.black54,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              tooltip: '삭제',
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 파트 추가/수정 다이얼로그 ──────────────────────────────────────────────

class _PartFormDialog extends StatefulWidget {
  final int lectureId;
  final InstructorPart? existing;

  const _PartFormDialog({required this.lectureId, this.existing});

  @override
  State<_PartFormDialog> createState() => _PartFormDialogState();
}

class _PartFormDialogState extends State<_PartFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _durationCtrl;
  bool _submitting = false;
  bool _fetchingDuration = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _urlCtrl = TextEditingController(text: p?.youtubeUrl ?? '');
    // 저장값은 초, 입력은 분 단위
    _durationCtrl = TextEditingController(
      text: p?.duration != null ? (p!.duration! ~/ 60).toString() : '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchYoutubeDuration() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube URL을 먼저 입력해 주세요')),
      );
      return;
    }

    setState(() => _fetchingDuration = true);
    try {
      final yt = YoutubeExplode();
      final videoId = VideoId.parseVideoId(url);
      if (videoId == null) {
        throw Exception('유효하지 않은 YouTube URL입니다');
      }
      final video = await yt.videos.get(videoId);
      yt.close();

      final totalSeconds = video.duration?.inSeconds ?? 0;
      final minutes = (totalSeconds / 60).ceil();
      if (mounted) {
        _durationCtrl.text = minutes.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상 시간을 가져오지 못했습니다: 직접 입력해 주세요')),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingDuration = false);
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('제목을 입력해 주세요')));
      return;
    }

    final url = _urlCtrl.text.trim();
    final minutesText = _durationCtrl.text.trim();
    final minutes = minutesText.isNotEmpty ? int.tryParse(minutesText) : null;
    // 분 → 초 변환
    final durationSeconds = minutes != null ? minutes * 60 : null;

    setState(() => _submitting = true);

    final state = context.read<PartManageState>();
    final bool success;

    if (_isEdit) {
      success = await state.updatePart(
        partId: widget.existing!.partId,
        lectureId: widget.lectureId,
        title: title,
        youtubeUrl: url.isNotEmpty ? url : null,
        duration: durationSeconds,
      );
    } else {
      success = await state.addPart(
        lectureId: widget.lectureId,
        title: title,
        youtubeUrl: url.isNotEmpty ? url : null,
        duration: durationSeconds,
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error ?? '저장에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEdit ? '파트 수정' : '파트 추가',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('제목 *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              maxLength: 100,
              decoration: const InputDecoration(hintText: '파트 제목'),
              autofocus: true,
            ),
            const SizedBox(height: 14),
            const Text('YouTube URL (선택)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(
                        hintText: 'https://youtu.be/...'),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 8),
                if (!kIsWeb)
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: (_fetchingDuration || _submitting)
                          ? null
                          : _fetchYoutubeDuration,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: _fetchingDuration
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('시간 가져오기',
                              style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('재생 시간 (분, 선택)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _durationCtrl,
              decoration: const InputDecoration(hintText: '예: 10 (10분)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEdit ? '저장' : '추가'),
        ),
      ],
    );
  }
}
