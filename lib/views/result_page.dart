import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/result_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../widgets/stat_card.dart';
import '../widgets/radar_chart.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // ── 완료 아이콘 ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎊', style: TextStyle(fontSize: 48)),
                ),
              ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 28),

              // ── 타이틀 ──
              Text(
                '오늘의 의정 활동 완료!',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 8),
              Text(
                '수고하셨습니다, 의원님! 👏\n비서실에서 결과를 정리했습니다.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: 36),

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

              const SizedBox(height: 24),

              // ── 비율 바 ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  boxShadow: AppConstants.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('표결 성향', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          if (controller.yesCount > 0)
                            Flexible(
                              flex: controller.yesCount,
                              child: Container(
                                height: 24,
                                color: AppColors.voteYes,
                                child: Center(
                                  child: Text(
                                    '${(controller.yesRatio * 100).toStringAsFixed(0)}%',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (controller.abstainCount > 0)
                            Flexible(
                              flex: controller.abstainCount,
                              child: Container(
                                height: 24,
                                color: AppColors.textSecondary,
                                child: Center(
                                  child: Text(
                                    '${(controller.abstainRatio * 100).toStringAsFixed(0)}%',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (controller.noCount > 0)
                            Flexible(
                              flex: controller.noCount,
                              child: Container(
                                height: 24,
                                color: AppColors.voteNo,
                                child: Center(
                                  child: Text(
                                    '${(controller.noRatio * 100).toStringAsFixed(0)}%',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend(AppColors.voteYes, '찬성'),
                        const SizedBox(width: 12),
                        _legend(AppColors.textSecondary, '기권'),
                        const SizedBox(width: 12),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppConstants.cardRadius),
                    boxShadow: AppConstants.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Text('분야별 찬성 성향 리포트', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 16),
                      Center(
                        child: RadarChart(
                          stats: controller.categoryStats,
                          size: 220,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 450.ms).slideY(
                    begin: 0.15, end: 0, delay: 1000.ms, duration: 450.ms);
              }),

              const SizedBox(height: 32),

              // ── 버튼들 ──
              Row(
                children: [
                  // 결과 공유 버튼
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: controller.shareResult,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 6),
                            Text(
                              '공유',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 소울메이트 찾기 버튼
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.goToRanking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🤝', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 6),
                            Text(
                              '매칭 의원 찾기',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),

              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.goHome,
                child: Text(
                  '의원실로 돌아가기',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
