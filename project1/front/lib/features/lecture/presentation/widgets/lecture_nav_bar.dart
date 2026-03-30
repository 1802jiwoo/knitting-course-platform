import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class LectureNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const LectureNavBar({
    super.key,
    required this.currentRoute,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64); // h-16

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            const Text(
              'LoopLearn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.foreground),
            ),
            const SizedBox(width: 32),

            // Search
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                onSubmitted: onSearch,
                style: const TextStyle(fontSize: 14, color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: '강의를 검색하세요...',
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
            const SizedBox(width: 32),

            // Nav Links
            _NavLink(
              label: '강의',
              isActive: currentRoute == AppRouter.lectureList,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.lectureList, (_) => false),
            ),
            const SizedBox(width: 24),
            _NavLink(
              label: '내 강의',
              isActive: currentRoute == AppRouter.myLectures,
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