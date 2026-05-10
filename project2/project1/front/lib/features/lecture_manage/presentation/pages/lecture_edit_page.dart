import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/instructor_lecture.dart';
import '../providers/lecture_manage_state.dart';

class LectureEditPage extends StatefulWidget {
  final InstructorLecture lecture;

  const LectureEditPage({super.key, required this.lecture});

  @override
  State<LectureEditPage> createState() => _LectureEditPageState();
}

class _LectureEditPageState extends State<LectureEditPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagCtrl;

  late String _lectureType;
  late List<String> _tags;
  bool _isSubmitting = false;
  Uint8List? _thumbnailBytes;
  String? _thumbnailFileName;

  static const _typeOptions = [
    ('PROJECT_CLASS', '프로젝트'),
    ('STITCH_BASICS', '기초 코바늘'),
    ('PATTERN', '도안'),
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.lecture;
    _titleCtrl = TextEditingController(text: l.title);
    _descCtrl = TextEditingController(text: l.description);
    _tagCtrl = TextEditingController();
    _lectureType = l.lectureType;
    _tags = List.of(l.tagNames);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleCtrl.text.trim().isNotEmpty && _descCtrl.text.trim().isNotEmpty;

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty) return;
    if (_tags.contains(tag)) {
      _tagCtrl.clear();
      return;
    }
    if (_tags.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('태그는 최대 10개까지 추가할 수 있습니다')),
      );
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
    });
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _thumbnailBytes = bytes;
      _thumbnailFileName = picked.name;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 설명을 입력해 주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<LectureManageState>().updateLecture(
          lectureId: widget.lecture.lectureId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          lectureType: _lectureType,
          tagNames: List.of(_tags),
          thumbnailBytes: _thumbnailBytes,
          thumbnailFileName: _thumbnailFileName,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('강의가 수정되었습니다')),
      );
      Navigator.pop(context);
    } else {
      final err =
          context.read<LectureManageState>().error ?? '강의 수정에 실패했습니다';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('강의 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('제목 *'),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLength: 100,
                  decoration: const InputDecoration(hintText: '강의 제목을 입력하세요'),
                ),
                const SizedBox(height: 20),

                _label('설명 *'),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  maxLines: 6,
                  maxLength: 2000,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '강의 설명을 입력하세요',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                _label('강의 유형 *'),
                const SizedBox(height: 4),
                ..._typeOptions.map(
                  (opt) => RadioListTile<String>(
                    value: opt.$1,
                    groupValue: _lectureType,
                    title: Text(opt.$2, style: const TextStyle(fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onChanged: (v) => setState(() => _lectureType = v!),
                  ),
                ),
                const SizedBox(height: 20),

                _label('썸네일 변경 (선택)'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickThumbnail,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _thumbnailBytes != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _thumbnailBytes = null;
                                    _thumbnailFileName = null;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : widget.lecture.thumbnailUrl != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    widget.lecture.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_outlined,
                                          size: 36, color: Colors.grey),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      color: Colors.black45,
                                      child: const Text(
                                        '탭하여 썸네일 변경',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 36, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('새 썸네일 선택 (변경하지 않으면 기존 유지)',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 20),

                _label('태그 (최대 10개, 선택)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagCtrl,
                        decoration: const InputDecoration(
                          hintText: '태그 입력 후 추가 버튼',
                        ),
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _addTag,
                      child: const Text('추가'),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag,
                                style: const TextStyle(fontSize: 13)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: Colors.black87,
                            labelStyle: const TextStyle(color: Colors.white),
                            deleteIconColor: Colors.white70,
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: (_canSubmit && !_isSubmitting) ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('저장',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      );
}
