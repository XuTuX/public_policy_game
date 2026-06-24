import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../models/assembly_member_model.dart';
import '../models/vote_model.dart';

class MatchResultCard extends StatelessWidget {
  final AssemblyMemberModel member;
  final bool isBestMatch;

  const MatchResultCard({
    super.key,
    required this.member,
    required this.isBestMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: AppConstants.cardShadow,
        border: Border.all(
          color: isBestMatch
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.voteNo.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildRankBadge(),
                const SizedBox(width: 16),
                _buildProfile(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: AppTextStyles.headlineSmall,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${member.matchRate.toStringAsFixed(0)}%',
                      style: AppTextStyles.headlineLarge.copyWith(
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Text(
              isBestMatch ? '✅ 이렇게 의견이 같았어요!' : '❌ 이렇게 의견이 달랐어요!',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._buildComparisonList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    final bgColor = isBestMatch ? AppColors.gold : AppColors.voteNo;
    final textColor = Colors.white;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          isBestMatch ? '1위' : '꼴찌',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final partyColor = AppColors.getPartyColor(member.party);

    return Container(
      width: 52,
      height: 52,
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
            fontSize: 20,
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

  List<Widget> _buildComparisonList() {
    final items = <Widget>[];

    for (final comp in member.comparisons) {
      final isMatch = comp.userVote == comp.memberVote.comparableChoice;
      
      if (isBestMatch && !isMatch) continue;
      if (!isBestMatch && isMatch) continue;

      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isMatch ? Icons.check_circle : Icons.cancel,
                color: isMatch ? AppColors.voteYes : AppColors.voteNo,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comp.billName,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '나: ${_voteTypeToString(comp.userVote)}  |  의원: ${_voteTypeToString(comp.memberVote.comparableChoice)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        Text(
          isBestMatch ? '일치한 법안이 없습니다.' : '불일치한 법안이 없습니다.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return items;
  }

  String _voteTypeToString(VoteType? type) {
    switch (type) {
      case VoteType.yes:
        return '찬성';
      case VoteType.no:
        return '반대';
      case VoteType.abstain:
        return '기권';
      default:
        return '알 수 없음';
    }
  }
}
