import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../widgets/app_error_widget.dart';

/// 홈 페이지 — 내러티브 인트로
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // 제거된 로딩 위젯: UI에 즉시 진입하도록 수정
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.onRefresh,
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Spacer(flex: 1),

                // ── 게임 내러티브 일러스트 / 아이콘 ──
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 78,
                        color: AppColors.primary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        delay: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),

                const Spacer(flex: 1),

                // ── 대화형 UI ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 프로필 아바타
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 이름 및 대화 말풍선
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '수석 보좌관',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(4), // 말풍선 꼬리 느낌
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  height: 1.6,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  const TextSpan(text: '오늘 검토할 본회의 안건이 '),
                                  TextSpan(
                                    text: controller.isLoading.value
                                        ? '...건'
                                        : '${controller.billCount}건',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const TextSpan(text: ' 준비되어 있습니다.\n각 안건의 쟁점을 확인해 보세요.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, delay: 600.ms),

                const SizedBox(height: 32),

                // ── CTA 버튼 ──
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.startVoting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: controller.isLoading.value ? 0 : 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: controller.isLoading.value
                          ? [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '안건 불러오는 중...',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ]
                          : [
                              Text(
                                '검토 시작하기',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded),
                            ],
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}
