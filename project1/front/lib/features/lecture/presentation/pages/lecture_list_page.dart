import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../features/lecture/domain/entities/lecture.dart';
import '../../../../features/lecture/domain/repositories/lecture_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/lecture_card.dart';
import '../widgets/lecture_filter_button.dart';
import '../widgets/lecture_nav_bar.dart';

const _lectureTypes = [
  _LectureTypeItem(code: null, label: '전체'),
  _LectureTypeItem(code: 'BASIC', label: '기초'),
  _LectureTypeItem(code: 'PROJECT', label: '작품'),
  _LectureTypeItem(code: 'PATTERN', label: '도안'),
];

class _LectureTypeItem {
  final String? code;
  final String label;
  const _LectureTypeItem({required this.code, required this.label});
}

class LectureListPage extends StatefulWidget {
  const LectureListPage({super.key, this.searchKeyword});

  final String? searchKeyword;

  @override
  State<LectureListPage> createState() => _LectureListPageState();
}

class _LectureListPageState extends State<LectureListPage> {
  String? _selectedType;
  String _searchKeyword = '';

  List<Lecture> _lectures = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if(widget.searchKeyword != 'null') {
      _searchKeyword = widget.searchKeyword!;
      setState(() {});
    }
    _fetchLectures();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchLectures() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = context.read<LectureRepository>();
      final result = await repo.getLectures(
        keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
      );
      if (mounted) setState(() { _lectures = result; _isLoading = false; });
    } catch (e) {
      print(e);
      if (mounted) setState(() { _error = '강의 목록을 불러오지 못했습니다.'; _isLoading = false; });
    }
  }

  List<Lecture> get _filtered => _lectures.where((l) {
    if (_selectedType != null && l.lectureType != _selectedType) return false;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LectureNavBar(
        currentRoute: AppRouter.lectureList,
        searchKeyword: _searchKeyword,
        onSearch: (v) {
          setState(() => _searchKeyword = v.trim());
          _fetchLectures();
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(context.isTablet ? 32 : 15, 32, context.isTablet ? 32 : 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    '뜨개질 강의',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '만들면서 배우는 실전 뜨개질 강의',
                    style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 32),

                  // Filter Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _lectureTypes.map((t) {
                        final isSelected = _selectedType == t.code;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: LectureFilterButton(
                            label: t.label,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedType = t.code),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Grid
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _fetchLectures, child: const Text('다시 시도')),
                ]),
              ),
            )
          else if (_filtered.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(context.isTablet ? 32 : 15, 0, context.isTablet ? 32 : 15, 32),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isTablet ? 4 : 1,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      final l = _filtered[i];
                      return LectureCard(
                        lecture: l,
                        isEnrolled: appState.isEnrolled(l.lectureId),
                        onTap: () => Navigator.pushNamed(
                          context, AppRouter.lectureDetail, arguments: l.lectureId,
                        ),
                      );
                    },
                    childCount: _filtered.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 48, color: Color(0xFFD1D5DB)),
          SizedBox(height: 12),
          Text(
            '강의가 없습니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.foreground),
          ),
          SizedBox(height: 4),
          Text(
            '선택한 카테고리에 해당하는 강의가 없습니다.',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}