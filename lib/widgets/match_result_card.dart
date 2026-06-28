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
          color: AppColors.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius - 1),
        child: Stack(
          children: [
            // Left accent colored bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 6,
              child: Container(
                color: isBestMatch ? AppColors.gold : AppColors.voteNo,
              ),
            ),
            // Content Column
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRankBadge(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildProfile(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                            style: AppTextStyles.displayMedium.copyWith(
                              color: _getMatchColor(member.matchRate),
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            '일치율',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
                  Text(
                    isBestMatch ? '일치한 표결' : '다르게 판단한 표결',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildComparisonList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    final bgColor = isBestMatch
        ? AppColors.gold.withValues(alpha: 0.12)
        : AppColors.voteNo.withValues(alpha: 0.1);
    final textColor = isBestMatch ? AppColors.gold : AppColors.voteNo;
    final labelText = isBestMatch ? '의견 일치 의원 1위' : '가장 낮은 일치율';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final partyColor = AppColors.getPartyColor(member.party);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: partyColor.withValues(alpha: 0.08),
        border: Border.all(
          color: partyColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          member.name.isNotEmpty ? member.name.substring(0, 1) : '',
          style: TextStyle(
            color: partyColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isMatch ? AppColors.voteYes : AppColors.voteNo,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comp.billName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildVoteBadge('나', comp.userVote),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 10, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        _buildVoteBadge('의원', comp.memberVote.comparableChoice),
                      ],
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            isBestMatch ? '일치한 법안이 없습니다.' : '불일치한 법안이 없습니다.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildVoteBadge(String who, VoteType? type) {
    Color color = AppColors.textSecondary;
    String label = '기권';
    if (type == VoteType.yes) {
      color = AppColors.voteYes;
      label = '찬성';
    } else if (type == VoteType.no) {
      color = AppColors.voteNo;
      label = '반대';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$who: $label',
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
