import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/member_detail_controller.dart';
import '../models/assembly_member_model.dart';
import '../models/vote_model.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';

/// 의원 상세 화면
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberDetailController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Obx(() => Text(
              controller.member.value?.name ?? '',
              style: AppTextStyles.headlineSmall,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final member = controller.member.value;
        if (member == null) {
          return const Center(child: Text('의원 정보를 불러올 수 없습니다'));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── 프로필 카드 ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  boxShadow: AppConstants.elevatedShadow,
                ),
                child: Column(
                  children: [
                    // 프로필 아바타
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.getPartyColor(member.party)
                            .withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.getPartyColor(member.party)
                              .withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          member.name.substring(0, 1),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getPartyColor(member.party),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(member.name, style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoChip(
                          AppColors.getPartyColor(member.party),
                          member.party,
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          AppColors.textTertiary,
                          member.district,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 일치율 대형
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getMatchColor(member.matchRate)
                                .withValues(alpha: 0.1),
                            _getMatchColor(member.matchRate)
                                .withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${member.matchRate.toStringAsFixed(0)}%',
                            style: AppTextStyles.statLarge.copyWith(
                              color: _getMatchColor(member.matchRate),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '일치',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: _getMatchColor(member.matchRate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 20),

              // ── 요약 통계 ──
              Row(
                children: [
                  _miniStat(
                    '일치',
                    '${controller.matchCount}',
                    AppColors.voteYes,
                  ),
                  const SizedBox(width: 12),
                  _miniStat(
                    '불일치',
                    '${controller.mismatchCount}',
                    AppColors.voteNo,
                  ),
                  const SizedBox(width: 12),
                  _miniStat(
                    '비교 총',
                    '${controller.totalCount}',
                    AppColors.primary,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // ── 법안별 비교 ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '법안별 비교',
                  style: AppTextStyles.headlineMedium,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 12),

              // 비교 리스트
              ...member.comparisons.asMap().entries.map((entry) {
                final index = entry.key;
                final comparison = entry.value;
                return _comparisonRow(comparison)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 500 + (index * 80)),
                      duration: 400.ms,
                    )
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: Duration(milliseconds: 500 + (index * 80)),
                      duration: 400.ms,
                    );
              }),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppConstants.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(VoteComparison comparison) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppConstants.cardShadow,
        border: Border.all(
          color: comparison.isMatch
              ? AppColors.voteYes.withValues(alpha: 0.15)
              : AppColors.voteNo.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // 법안명
          Expanded(
            flex: 3,
            child: Text(
              comparison.billName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // 나의 선택
          _voteChip('나', comparison.userVote),
          const SizedBox(width: 6),
          // 의원 선택
          _voteChip('의원', comparison.memberVote),
          const SizedBox(width: 8),
          // 같음/다름
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: comparison.isMatch
                  ? AppColors.voteYesBg
                  : AppColors.voteNoBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comparison.isMatch ? '✓' : '✗',
                style: TextStyle(
                  color: comparison.isMatch
                      ? AppColors.voteYes
                      : AppColors.voteNo,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voteChip(String label, VoteType vote) {
    final isYes = vote == VoteType.yes;
    final color = isYes ? AppColors.voteYes : AppColors.voteNo;

    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            vote.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getMatchColor(double rate) {
    if (rate >= 80) return AppColors.accent;
    if (rate >= 60) return AppColors.secondary;
    if (rate >= 40) return AppColors.warning;
    return AppColors.textTertiary;
  }
}
