import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';

/// AI 요약 카드 (발의 배경 / 장점 / 문제점)
class SummaryCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  /// 발의 배경 카드
  factory SummaryCard.background(String content) {
    return SummaryCard(
      title: '발의 배경',
      content: content,
      icon: Icons.lightbulb_outline_rounded,
      iconColor: AppColors.secondary,
      bgColor: AppColors.secondarySurface,
    );
  }

  /// 장점 카드
  factory SummaryCard.pros(String content) {
    return SummaryCard(
      title: '장점',
      content: content,
      icon: Icons.thumb_up_outlined,
      iconColor: AppColors.accent,
      bgColor: AppColors.accentSurface,
    );
  }

  /// 문제점 카드
  factory SummaryCard.cons(String content) {
    return SummaryCard(
      title: '문제점',
      content: content,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      bgColor: const Color(0xFFFFFBEB),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
