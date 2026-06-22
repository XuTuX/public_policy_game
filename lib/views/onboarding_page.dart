import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/onboarding_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

/// 온보딩 페이지
/// "오늘부터 당신도 국회의원입니다"
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🏛️',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 40),
              // 타이틀
              Text(
                '오늘부터\n당신도 국회의원입니다',
                style: AppTextStyles.displayLarge.copyWith(
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 16),
              // 서브텍스트
              Text(
                '실제 국회 법안에 직접 투표하고\n나와 성향이 비슷한 의원을 찾아보세요',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms),
              const SizedBox(height: 32),
              // 피처 리스트
              _buildFeatureItem(
                '📋',
                'AI가 요약한 법안을 쉽게 읽어보세요',
                delay: 800,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                '🗳️',
                'O / X로 간단하게 투표하세요',
                delay: 950,
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                '🤝',
                '나와 비슷한 국회의원을 찾아드려요',
                delay: 1100,
              ),
              const Spacer(flex: 3),
              // 시작하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.onStartTapped,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '시작하기',
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1300.ms, duration: 500.ms)
                  .slideY(
                      begin: 0.5, end: 0, delay: 1300.ms, duration: 500.ms),
              const SizedBox(height: 16),
              Text(
                '소요 시간: 약 5분',
                style: AppTextStyles.caption,
              ).animate().fadeIn(delay: 1500.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text, {int delay = 0}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        );
  }
}
