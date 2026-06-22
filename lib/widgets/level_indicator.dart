import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../models/user_profile_model.dart';

/// 레벨 표시 위젯
class LevelIndicator extends StatelessWidget {
  final UserProfileModel profile;

  const LevelIndicator({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final levelInfo = profile.levelInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // 레벨 이모지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                levelInfo.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 레벨 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lv.${levelInfo.level}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      levelInfo.title,
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  percent: profile.progressToNextLevel,
                  lineHeight: 6,
                  padding: EdgeInsets.zero,
                  barRadius: const Radius.circular(3),
                  backgroundColor: AppColors.surfaceVariant,
                  linearGradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.votesToNextLevel > 0
                      ? '다음 레벨까지 ${profile.votesToNextLevel}표'
                      : '최고 레벨 달성!',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
