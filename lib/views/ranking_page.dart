import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/ranking_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../widgets/ranking_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_error_widget.dart';

/// 국회의원 매칭 화면
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RankingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('나의 정치 소울메이트', style: AppTextStyles.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '나와 비슷한 의원을 찾고 있습니다...');
        }
        if (controller.hasError.value) {
          return const AppErrorWidget(message: '매칭 결과를 불러올 수 없습니다');
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 헤더 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신의 표결과 가장 비슷한\n국회의원은? 🤔',
                      style: AppTextStyles.headlineLarge,
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      '실제 국회의원의 본회의 표결과 비교한 결과입니다',
                      style: AppTextStyles.bodyMedium,
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── 1위 강조 ──
            if (controller.topMember != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 왕관 + 1위 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.15),
                              AppColors.gold.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '나의 정치 소울메이트',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            delay: 400.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

            // ── 랭킹 리스트 ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: Obx(() => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = controller.rankedMembers[index];
                        return RankingCard(
                          member: member,
                          rank: index + 1,
                          onTap: () => controller.goToMemberDetail(member),
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 500 + (index * 100)),
                              duration: 400.ms,
                            )
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              delay: Duration(milliseconds: 500 + (index * 100)),
                              duration: 400.ms,
                            );
                      },
                      childCount: controller.rankedMembers.length,
                    ),
                  )),
            ),

            // ── 하단 버튼 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: controller.goHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '홈으로 돌아가기',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
