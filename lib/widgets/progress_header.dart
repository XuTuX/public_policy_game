import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

/// 진행률 표시 위젯
class ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final double progress;

  const ProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$current',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${total - current}개 남음',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearPercentIndicator(
          percent: progress.clamp(0.0, 1.0),
          lineHeight: 8,
          padding: EdgeInsets.zero,
          barRadius: const Radius.circular(4),
          backgroundColor: AppColors.surfaceVariant,
          linearGradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          animation: true,
          animationDuration: 400,
          animateFromLastPercent: true,
        ),
      ],
    );
  }
}
