import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../models/assembly_member_model.dart';

/// 의원 랭킹 카드
class RankingCard extends StatelessWidget {
  final AssemblyMemberModel member;
  final int rank;
  final VoidCallback? onTap;

  const RankingCard({
    super.key,
    required this.member,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= 3;
    final isFirst = rank == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: isFirst ? AppConstants.elevatedShadow : AppConstants.cardShadow,
          border: isFirst
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 2)
              : isTop
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15), width: 1)
                  : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(isFirst ? 20 : 16),
          child: Row(
            children: [
              // 순위 뱃지
              _buildRankBadge(),
              SizedBox(width: isFirst ? 16 : 12),
              // 프로필
              _buildProfile(),
              const SizedBox(width: 12),
              // 의원 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: isFirst
                          ? AppTextStyles.headlineSmall
                          : AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.getPartyColor(member.party),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${member.party} · ${member.district}',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 일치율
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${member.matchRate.toStringAsFixed(0)}%',
                    style: (isFirst
                            ? AppTextStyles.headlineLarge
                            : AppTextStyles.headlineMedium)
                        .copyWith(
                      color: _getMatchColor(member.matchRate),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '일치율',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color bgColor;
    Color textColor;
    double size;

    switch (rank) {
      case 1:
        bgColor = AppColors.gold;
        textColor = Colors.white;
        size = 36;
        break;
      case 2:
        bgColor = AppColors.silver;
        textColor = Colors.white;
        size = 32;
        break;
      case 3:
        bgColor = AppColors.bronze;
        textColor = Colors.white;
        size = 32;
        break;
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
        size = 28;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: rank <= 3 ? 14 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final size = rank == 1 ? 52.0 : 44.0;
    final partyColor = AppColors.getPartyColor(member.party);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: partyColor.withValues(alpha: 0.1),
        border: Border.all(
          color: partyColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          member.name.substring(0, 1),
          style: TextStyle(
            color: partyColor,
            fontWeight: FontWeight.w700,
            fontSize: rank == 1 ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Color _getMatchColor(double rate) {
    if (rate >= 80) return AppColors.accent;
    if (rate >= 60) return AppColors.secondary;
    if (rate >= 40) return AppColors.warning;
    return AppColors.textTertiary;
  }
}
