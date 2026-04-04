import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class LectureNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String currentRoute;
  final ValueChanged<String>? onSearch;
  final String searchKeyword;

  const LectureNavBar({
    super.key,
    required this.currentRoute,
    this.onSearch,
    this.searchKeyword = '',
  });

  @override
  Size get preferredSize => const Size.fromHeight(64); // h-16

  @override
  State<LectureNavBar> createState() => _LectureNavBarState();
}

class _LectureNavBarState extends State<LectureNavBar> {
  TextEditingController searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchController.text = widget.searchKeyword;
      setState(() {});
    },);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.card,
      elevation: 0,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.isTablet ? 32 : 15),
        child: Row(
          children: [
            // Logo
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'L',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            if(context.isTablet) const Text(
              'LoopLearn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.foreground),
            ),
            SizedBox(width: context.isTablet ? 32 : 15),

            // Search
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: widget.onSearch ?? (v) {
                  setState(() => _searchKeyword = v.trim());
                },
                onSubmitted: widget.onSearch ?? (v) {
                  setState(() => _searchKeyword = v.trim());
                  Navigator.pushReplacementNamed(
                    context, AppRouter.lectureList,
                    arguments: _searchKeyword,
                  );
                },
                style: const TextStyle(fontSize: 14, color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: '강의를 검색하세요.',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mutedForeground),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: AppColors.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.isTablet ? 32 : 15),

            // Nav Links
            _NavLink(
              label: '강의',
              isActive: widget.currentRoute == AppRouter.lectureList,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.lectureList, (_) => false),
            ),
            const SizedBox(width: 24),
            _NavLink(
              label: '내 강의',
              isActive: widget.currentRoute == AppRouter.myLectures,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.myLectures, (_) => false),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.primary : AppColors.foreground,
        ),
      ),
    );
  }
}