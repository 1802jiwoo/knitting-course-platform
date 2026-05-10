import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/instructor_part_pattern.dart';
import '../providers/part_pattern_manage_state.dart';

class PartPatternManagePage extends StatefulWidget {
  final int partId;
  final String partTitle;

  const PartPatternManagePage({
    super.key,
    required this.partId,
    required this.partTitle,
  });

  @override
  State<PartPatternManagePage> createState() => _PartPatternManagePageState();
}

class _PartPatternManagePageState extends State<PartPatternManagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartPatternManageState>().loadPatterns(widget.partId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PartPatternManageState>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('파트 도안 관리'),
            Text(
              widget.partTitle,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPatternDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('도안 추가'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PartPatternManageState state) {
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
                state.loadPatterns(widget.partId);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.patterns.isEmpty) {
      return const Center(
        child: Text(
          '등록된 도안이 없습니다.\n도안을 추가해 주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.patterns.length,
      itemBuilder: (context, index) {
        final pattern = state.patterns[index];
        return _PartPatternTile(
          key: ValueKey(pattern.patternId),
          pattern: pattern,
          onEdit: () => _showPatternDialog(context, existing: pattern),
          onDelete: () => _confirmDelete(context, pattern),
        );
      },
    );
  }

  void _showPatternDialog(BuildContext context,
      {InstructorPartPattern? existing}) {
    showDialog(
      context: context,
      builder: (_) => _PartPatternFormDialog(
        partId: widget.partId,
        existing: existing,
      ),
    );
  }

  void _confirmDelete(BuildContext context, InstructorPartPattern pattern) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('도안 삭제', style: TextStyle(fontSize: 16)),
        content: Text('${pattern.rowNum}단 도안을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<PartPatternManageState>().deletePattern(
                        partId: widget.partId,
                        patternId: pattern.patternId,
                      );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<PartPatternManageState>().error ??
                          '삭제에 실패했습니다.',
                    ),
                  ),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// ── 도안 행 타일 ────────────────────────────────────────────────────────────

class _PartPatternTile extends StatelessWidget {
  final InstructorPartPattern pattern;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PartPatternTile({
    super.key,
    required this.pattern,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
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
        leading: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${pattern.rowNum}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          pattern.patternText,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            '${_formatTime(pattern.startTime)} ~ ${_formatTime(pattern.endTime)}',
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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

// ── 도안 추가/수정 다이얼로그 ─────────────────────────────────────────────────

class _PartPatternFormDialog extends StatefulWidget {
  final int partId;
  final InstructorPartPattern? existing;

  const _PartPatternFormDialog({required this.partId, this.existing});

  @override
  State<_PartPatternFormDialog> createState() => _PartPatternFormDialogState();
}

class _PartPatternFormDialogState extends State<_PartPatternFormDialog> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _textCtrl;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _startCtrl = TextEditingController(text: p != null ? '${p.startTime}' : '');
    _endCtrl = TextEditingController(text: p != null ? '${p.endTime}' : '');
    _textCtrl = TextEditingController(text: p?.patternText ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final startText = _startCtrl.text.trim();
    final endText = _endCtrl.text.trim();
    final text = _textCtrl.text.trim();

    final startTime = int.tryParse(startText);
    final endTime = int.tryParse(endText);

    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작/종료 시간을 올바르게 입력해 주세요')),
      );
      return;
    }
    if (endTime <= startTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시간은 시작 시간보다 커야 합니다')),
      );
      return;
    }
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('도안 내용을 입력해 주세요')),
      );
      return;
    }

    setState(() => _submitting = true);
    final state = context.read<PartPatternManageState>();
    final bool success;

    if (_isEdit) {
      success = await state.updatePattern(
        partId: widget.partId,
        patternId: widget.existing!.patternId,
        startTime: startTime,
        endTime: endTime,
        patternText: text,
      );
    } else {
      success = await state.addPattern(
        partId: widget.partId,
        startTime: startTime,
        endTime: endTime,
        patternText: text,
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
        _isEdit ? '도안 수정' : '도안 추가',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시작 시간 (초) *',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _startCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(hintText: '예: 30'),
                        autofocus: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('종료 시간 (초) *',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _endCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(hintText: '예: 60'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('도안 내용 *',
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '예: sc sc inc x6',
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
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
