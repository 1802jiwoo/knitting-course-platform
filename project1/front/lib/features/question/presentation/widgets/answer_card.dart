import 'package:flutter/material.dart';
import 'package:loop_learn/core/theme/app_colors.dart';

import '../../domain/entities/answer.dart';

class AnswerCard extends StatelessWidget {
  final Answer answer;

  const AnswerCard({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.muted),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아바타
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    answer.nickname.isNotEmpty ? answer.nickname[0] : '강',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 작성자 + 날짜 (한 Row로)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          answer.nickname,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          answer.createdAt.toString().substring(0, 10),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 내용: 아바타(32) + 간격(10) 만큼 들여쓰기
          Padding(
            padding: const EdgeInsets.only(left: 42, top: 8),
            child: Text(
              answer.content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.foreground,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}