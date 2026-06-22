import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/badge_model.dart';

/// 배지 표시 위젯
class BadgeWidget extends StatelessWidget {
  final BadgeModel badge;
  final double size;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.isUnlocked ? badge.description : '???',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? AppColors.primarySurface
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: badge.isUnlocked
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
                  : null,
            ),
            child: Center(
              child: Text(
                badge.isUnlocked ? badge.emoji : '🔒',
                style: TextStyle(fontSize: size * 0.4),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 12,
            child: Text(
              badge.isUnlocked ? badge.name : '???',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: badge.isUnlocked
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
