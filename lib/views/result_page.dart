import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/result_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../widgets/stat_card.dart';

/// 결과 화면 — "오늘의 의정 활동 결과"
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResultController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            return Column(
              children: [
                const Spacer(flex: 1),
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
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
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
                  '수고하셨습니다, 의원님! 👏',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 36),

                // ── 통계 카드들 ──
                Row(
                  children: [
                    StatCard(
                      label: '참여 법안',
                      value: '${controller.totalBills}',
                      icon: Icons.description_outlined,
                      color: AppColors.primary,
                      bgColor: AppColors.primarySurface,
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      label: '찬성',
                      value: '${controller.yesCount}',
                      icon: Icons.check_circle_outline,
                      color: AppColors.voteYes,
                      bgColor: AppColors.voteYesBg,
                    ),
                    const SizedBox(width: 12),
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
                        children: [
                          _legend(AppColors.voteYes, '찬성'),
                          const SizedBox(width: 16),
                          _legend(AppColors.voteNo, '반대'),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // ── 버튼들 ──
                SizedBox(
                  width: double.infinity,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🤝', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text('나와 비슷한 의원 찾기',
                            style: AppTextStyles.buttonLarge),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.goHome,
                  child: Text(
                    '홈으로 돌아가기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),

                const SizedBox(height: 32),
              ],
            );
          }),
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
