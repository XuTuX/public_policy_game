import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../widgets/mission_card.dart';
import '../widgets/level_indicator.dart';
import '../widgets/badge_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/empty_widget.dart';

/// 홈 페이지 — "오늘의 본회의"
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '본회의를 준비하고 있습니다...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.onRefresh,
          );
        }
        if (controller.bills.isEmpty) {
          return const EmptyWidget(
            title: '오늘의 법안이 없습니다',
            subtitle: '내일 다시 확인해주세요!',
            icon: Icons.event_busy_rounded,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 인사
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '오늘의 본회의 🏛️',
                                  style: AppTextStyles.displayMedium,
                                ).animate().fadeIn(duration: 400.ms),
                                const SizedBox(height: 4),
                                Text(
                                  '오늘 처리할 법안이 도착했습니다',
                                  style: AppTextStyles.bodyMedium,
                                ).animate().fadeIn(
                                    delay: 200.ms, duration: 400.ms),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── 레벨 표시 ──
                        Obx(() => LevelIndicator(
                              profile: controller.userProfile.value,
                            ))
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms)
                            .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 300.ms,
                                duration: 400.ms),
                        const SizedBox(height: 16),

                        // ── 배지 ──
                        Obx(() {
                          final badges =
                              controller.userProfile.value.badges;
                          if (badges.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '획득한 배지',
                                style: AppTextStyles.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: badges.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return BadgeWidget(badge: badges[index]);
                                  },
                                ),
                              ),
                            ],
                          );
                        })
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 400.ms),
                        const SizedBox(height: 24),

                        // ── 오늘의 법안 제목 ──
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '오늘의 표결 미션',
                              style: AppTextStyles.headlineMedium,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${controller.billCount}개 · 약 ${controller.totalEstimatedMinutes}분',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(
                            delay: 600.ms, duration: 400.ms),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 법안 카드 리스트 ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: Obx(() => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return MissionCard(
                            bill: controller.bills[index],
                            index: index,
                          )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                    milliseconds: 700 + (index * 80)),
                                duration: 400.ms,
                              )
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                delay: Duration(
                                    milliseconds: 700 + (index * 80)),
                                duration: 400.ms,
                              );
                        },
                        childCount: controller.bills.length,
                      ),
                    )),
              ),

              // ── 하단 여백 + CTA 버튼 ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.startVoting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🗳️',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '표결 시작',
                            style: AppTextStyles.buttonLarge,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
