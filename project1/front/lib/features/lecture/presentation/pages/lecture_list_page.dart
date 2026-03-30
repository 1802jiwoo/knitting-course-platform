import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../widgets/shared_widgets.dart';

const _lectureTypes = [
  _LectureTypeItem(code: null,      label: '전체'),
  _LectureTypeItem(code: 'BASIC',   label: '기초 학습'),
  _LectureTypeItem(code: 'PROJECT', label: '작품 제작'),
  _LectureTypeItem(code: 'PATTERN', label: '도안'),
];

class _LectureTypeItem {
  final String? code;
  final String label;
  const _LectureTypeItem({required this.code, required this.label});
}

class LectureListPage extends StatefulWidget {
  const LectureListPage({super.key});

  @override
  State<LectureListPage> createState() => _LectureListPageState();
}

class _LectureListPageState extends State<LectureListPage> {
  String? _selectedType;
  String _searchKeyword = '';

  // API 상태
  List<Lecture> _lectures = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLectures();
  }

  Future<void> _fetchLectures() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = context.read<LectureRepository>();
      final result = await repo.getLectures(
        title: _searchKeyword.isEmpty ? null : _searchKeyword,
        instructor: _searchKeyword.isEmpty ? null : _searchKeyword,
      );
      if (mounted) setState(() { _lectures = result; _isLoading = false; });
    } catch (e) {
      print(e);
      if (mounted) setState(() { _error = '강의 목록을 불러오지 못했습니다.'; _isLoading = false; });
    }
  }

  // 유형 필터는 클라이언트에서 처리 (API에 lectureType 파라미터 없음)
  List<Lecture> get _filtered {
    return _lectures.where((l) {
      if (_selectedType != null && l.lectureType != _selectedType) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: LoopLearnNavBar(currentRoute: AppRouter.lectureList),
      body: Row(
        children: [
          _TypeSidebar(
            selectedType: _selectedType,
            onTypeSelected: (type) => setState(() => _selectedType = type),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '강의 검색 (제목, 강사명, 태그)...',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                    ),
                    onSubmitted: (_) => _fetchLectures(),
                    onChanged: (v) => setState(() => _searchKeyword = v.trim()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(children: [
                    Text(
                      _selectedType == null ? '전체 강의' : _typeLabel(_selectedType!),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    if (!_isLoading)
                      Text('${_filtered.length}개',
                          style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ]),
                ),
                Expanded(child: _buildBody(appState)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppState appState) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, style: const TextStyle(color: Colors.black45)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _fetchLectures, child: const Text('다시 시도')),
      ]),
    );
    if (_filtered.isEmpty) return const Center(
      child: Text('검색 결과가 없습니다', style: TextStyle(color: Colors.black45)),
    );

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final l = _filtered[i];
        return _LectureCard(
          lecture: l,
          isEnrolled: appState.isEnrolled(l.lectureId),
          onTap: () => Navigator.pushNamed(context, AppRouter.lectureDetail, arguments: l.lectureId),
        );
      },
    );
  }

  String _typeLabel(String code) {
    switch (code) {
      case 'BASIC':   return '기초 학습';
      case 'PROJECT': return '작품 제작';
      case 'PATTERN': return '도안';
      default:        return '전체 강의';
    }
  }
}

class _TypeSidebar extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;
  const _TypeSidebar({required this.selectedType, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('강의 유형', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: Colors.black45, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 6),
          ..._lectureTypes.map((t) => _TypeItem(
            label: t.label,
            isSelected: selectedType == t.code,
            onTap: () => onTypeSelected(t.code),
          )),
        ],
      ),
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        color: isSelected ? Colors.grey.shade100 : Colors.transparent,
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.black87 : Colors.transparent,
              border: Border.all(color: isSelected ? Colors.black87 : Colors.black26),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.black87 : Colors.black54,
          )),
        ]),
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  final Lecture lecture;
  final bool isEnrolled;
  final VoidCallback onTap;
  const _LectureCard({required this.lecture, required this.isEnrolled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tagNames = (lecture is dynamic && (lecture as dynamic).tagNames != null)
        ? (lecture as dynamic).tagNames as List<String>
        : <String>[];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                border: const Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: const Center(child: Icon(Icons.play_circle_outline, size: 32, color: Colors.black26)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LectureTypeBadge(lectureType: lecture.lectureType),
                    const SizedBox(height: 4),
                    Text(lecture.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(lecture.instructorName,
                        style: const TextStyle(fontSize: 10, color: Colors.black45)),
                    const Spacer(),
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: tagNames.take(2).map((t) => TagPill(label: t)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(11, 6, 11, 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: isEnrolled ? Colors.black26 : Colors.black54),
                    borderRadius: BorderRadius.circular(6),
                    color: isEnrolled ? Colors.grey.shade100 : Colors.transparent,
                  ),
                  child: Text(
                    isEnrolled ? '수강 중' : '수강 신청',
                    style: TextStyle(fontSize: 11, color: isEnrolled ? Colors.black45 : Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
