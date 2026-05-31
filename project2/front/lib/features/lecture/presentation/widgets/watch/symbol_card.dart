import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class SymbolCard extends StatelessWidget {
  final String abbreviation;
  final String name;

  const SymbolCard({super.key, required this.abbreviation, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            abbreviation,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
