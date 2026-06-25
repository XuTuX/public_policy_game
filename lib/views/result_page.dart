import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/result_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../widgets/stat_card.dart';
import '../widgets/radar_chart.dart';
import '../widgets/match_result_card.dart';

/// 결과 화면 — "오늘의 의정 활동 결과"
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResultController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              RepaintBoundary(
                key: controller.shareKey,
                child: Container(
                  color: AppColors.background, // 이미지 캡쳐를 위한 공통 고체 배경색 지정
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // ── 완료 아이콘 ──
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.accent.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text('🗳️', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 24),

                      // ── 타이틀 ──
                      Text(
                        '오늘의 의정 활동 완료!',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 400.ms)
                          .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 400.ms),

                      const SizedBox(height: 10),
                      Text(
                        '수고하셨습니다, 의원님! 👏\n비서실에서 결과를 정리했습니다.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                      const SizedBox(height: 32),

                      // ── 통계 카드들 ──
                      Row(
                        children: [
                          StatCard(
                            label: '찬성',
                            value: '${controller.yesCount}',
                            icon: Icons.check_circle_outline,
                            color: AppColors.voteYes,
                            bgColor: AppColors.voteYesBg,
                          ),
                          const SizedBox(width: 8),
                          StatCard(
                            label: '기권',
                            value: '${controller.abstainCount}',
                            icon: Icons.remove_circle_outline,
                            color: AppColors.textSecondary,
                            bgColor: AppColors.surfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          StatCard(
                            label: '반대',
                            value: '${controller.noCount}',
                            icon: Icons.cancel_outlined,
                            color: AppColors.voteNo,
                            bgColor: AppColors.voteNoBg,
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 400.ms),

                      const SizedBox(height: 20),

                      // ── 비율 바 ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                          border: Border.all(
                            color: AppColors.divider.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: AppConstants.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '표결 성향 분석',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: [
                                  if (controller.yesCount > 0)
                                    Flexible(
                                      flex: controller.yesCount,
                                      child: Container(
                                        height: 16,
                                        color: AppColors.voteYes,
                                        child: Center(
                                          child: Text(
                                            '${(controller.yesRatio * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (controller.abstainCount > 0)
                                    Flexible(
                                      flex: controller.abstainCount,
                                      child: Container(
                                        height: 16,
                                        color: AppColors.textSecondary,
                                        child: Center(
                                          child: Text(
                                            '${(controller.abstainRatio * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (controller.noCount > 0)
                                    Flexible(
                                      flex: controller.noCount,
                                      child: Container(
                                        height: 16,
                                        color: AppColors.voteNo,
                                        child: Center(
                                          child: Text(
                                            '${(controller.noRatio * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _legend(AppColors.voteYes, '찬성'),
                                const SizedBox(width: 20),
                                _legend(AppColors.textSecondary, '기권'),
                                const SizedBox(width: 20),
                                _legend(AppColors.voteNo, '반대'),
                              ],
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 900.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 400.ms),

                      const SizedBox(height: 20),

                      // ── 카테고리별 성향 다이어그램 ──
                      Obx(() {
                        if (controller.isStatsLoading.value) {
                          return const SizedBox(
                            height: 180,
                            child: Center(
                              child:
                                  CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }
                        if (controller.categoryStats.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius:
                                BorderRadius.circular(AppConstants.cardRadius),
                            border: Border.all(
                              color: AppColors.divider.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: AppConstants.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '분야별 찬성 성향 리포트',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '각 법안 카테고리별로 찬성 투표를 던진 비율입니다.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: RadarChart(
                                  stats: controller.categoryStats,
                                  size: 220,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 32),

                      // ── 매칭 결과 (Best) ──
                      Obx(() {
                        if (controller.isStatsLoading.value) {
                          return const SizedBox.shrink();
                        }
                        
                        final bestMatch = controller.bestMatch.value;

                        if (bestMatch == null) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '나의 정치 소울메이트 🤝',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),
                            const SizedBox(height: 16),
                            MatchResultCard(
                              member: bestMatch,
                              isBestMatch: true,
                            ).animate().fadeIn(delay: 1200.ms, duration: 400.ms).slideY(
                                  begin: 0.1,
                                  end: 0,
                                ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 버튼들
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.shareResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '결과 공유하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 1500.ms, duration: 400.ms),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: controller.goHome,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '의원실로 돌아가기',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1600.ms, duration: 400.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
