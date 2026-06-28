import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/result_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

import 'result_detail_page.dart';

class PersonalityResult {
  final String title;
  final String emoji;
  final String catchphrase;
  final List<String> traits;
  final List<Color> gradientColors;

  PersonalityResult({
    required this.title,
    required this.emoji,
    required this.catchphrase,
    required this.traits,
    required this.gradientColors,
  });
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  PersonalityResult _analyzePersonality(ResultController controller) {
    final yes = controller.yesRatio;
    final no = controller.noRatio;
    final abstain = controller.abstainRatio;

    if (abstain > 0.4) {
      return PersonalityResult(
        title: '합리적 중도파',
        emoji: '⚖️',
        catchphrase: '어느 한쪽으로 치우치지 않는 균형감각의 소유자',
        traits: ['신중함', '균형감각', '데이터 중심'],
        gradientColors: [AppColors.secondary, AppColors.primaryLight],
      );
    } else if (yes > 0.6) {
      return PersonalityResult(
        title: '진취적 개혁가',
        emoji: '🔥',
        catchphrase: '변화와 혁신을 두려워하지 않는 뜨거운 심장',
        traits: ['진취적', '행동파', '미래지향'],
        gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFCA048)],
      );
    } else if (no > 0.6) {
      return PersonalityResult(
        title: '신중한 보수파',
        emoji: '🛡️',
        catchphrase: '돌다리도 두들겨 보고 건너는 안정 추구형',
        traits: ['신중함', '안정추구', '현실주의'],
        gradientColors: [const Color(0xFF4A90E2), const Color(0xFF50E3C2)],
      );
    } else if (yes > 0.4 && no > 0.4) {
      return PersonalityResult(
        title: '소신있는 비판가',
        emoji: '💡',
        catchphrase: '확실한 주관으로 찬반을 명확히 하는 팩트폭격기',
        traits: ['소신파', '주관뚜렷', '비판적 사고'],
        gradientColors: [const Color(0xFF9B51E0), const Color(0xFF56CCF2)],
      );
    } else {
      return PersonalityResult(
        title: '현실주의 실용파',
        emoji: '🎯',
        catchphrase: '이념보다는 실제적인 문제 해결에 집중하는 타입',
        traits: ['현실적', '실용주의', '문제해결'],
        gradientColors: [AppColors.accent, AppColors.secondaryLight],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResultController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isStatsLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final personality = _analyzePersonality(controller);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 뒤로가기 버튼 영역
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 28),
                    onPressed: controller.goHome,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 캡처 영역 (프리미엄 카드)
                RepaintBoundary(
                  key: controller.shareKey,
                  child: Container(
                    padding: const EdgeInsets.all(2), // 그라데이션 테두리를 위한 패딩
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: personality.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: personality.gradientColors.first.withValues(alpha: 0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 상단 로고/타이틀
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'POLITICAL PERSONA',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          
                          // 이모지 강조 영역 (그라데이션 후광 효과)
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  personality.gradientColors.first.withValues(alpha: 0.2),
                                  personality.gradientColors.last.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow.withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    personality.emoji,
                                    style: const TextStyle(fontSize: 50),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 600.ms),
                          const SizedBox(height: 32),
                          
                          // 성향 타이틀
                          Text(
                            personality.title,
                            style: AppTextStyles.displayMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 12),
                          
                          // 캐치프레이즈
                          Text(
                            personality.catchphrase,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                          const SizedBox(height: 36),
                          
                          // 특징 칩스 (Pill 형태)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: personality.traits.map((trait) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: personality.gradientColors.first.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: personality.gradientColors.first.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  trait,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: personality.gradientColors.first.withValues(alpha: 1.0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                          
                          const SizedBox(height: 40),
                          const Divider(color: AppColors.divider, thickness: 1),
                          const SizedBox(height: 32),
                          
                          // 매칭 의원 섹션 (클릭 시 새 화면으로 이동)
                          if (controller.bestMatch.value != null) ...[
                            Text(
                              '🤝 나와 가장 닮은 국회의원',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => Get.to(() => const ResultDetailPage(), transition: Transition.rightToLeft),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.getPartyColor(controller.bestMatch.value!.party),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${controller.bestMatch.value!.name} 의원',
                                      style: AppTextStyles.headlineSmall.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      controller.bestMatch.value!.party,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          
                          // 하단 워터마크
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: personality.gradientColors,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '오늘부터 국회의원',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                
                const SizedBox(height: 32),
                
                // 액션 버튼 영역
                ElevatedButton(
                  onPressed: () => controller.shareResult(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.textPrimary.withValues(alpha: 0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ios_share_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        '이 결과 카드 자랑하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 16),
                
                // 밖으로 뺀 자세히 보기 버튼
                if (controller.bestMatch.value != null)
                  TextButton(
                    onPressed: () => Get.to(() => const ResultDetailPage(), transition: Transition.rightToLeft),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '내 표결 성향 상세 분석 보기',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }
}
