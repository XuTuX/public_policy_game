import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

/// 웹 브라우저 등 가로 너비가 넓은 스크린에서 스마트폰 크기의 프레임을 제공하고,
/// 좌측에는 브랜드 소개 패널을 배치하여 전문적이고 깔끔한 웹 전용 화면을 만들어주는 반응형 래퍼 위젯.
class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const WebResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 높이가 낮은 가로 창에서는 디바이스 프레임이 화면 밖으로 넘치므로
    // 모바일 레이아웃을 그대로 사용한다.
    final isWideScreen = size.width > 600 && size.height >= 640;

    if (!isWideScreen) {
      return child;
    }

    // 스마트폰 프레임 디자인 사양
    const double phoneWidth = 412;
    const double maxPhoneHeight = 860;
    // 브라우저 높이에 맞춰 높이를 적절히 조절
    final double phoneHeight = min(maxPhoneHeight, size.height - 48);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Stack(
        children: [
          // ── 배경 오로라 이펙트 (Mesh Blur 데코레이션) ──
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 블러 필터 적용
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── 메인 레이아웃 ──
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 좌측 브랜드 가이드 (너비가 1000px 이상일 때만 노출)
                    if (size.width > 1000 && size.height >= 600)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 64),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 뱃지
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🏛️',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '국회 법안 투표 시뮬레이션 게임',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .slideY(begin: -0.1, end: 0),
                                const SizedBox(height: 24),
  
                                // 타이틀 그라데이션 텍스트
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Text(
                                    '오늘부터 국회의원',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 150.ms, duration: 400.ms),
                                const SizedBox(height: 16),
  
                                Text(
                                  '당신은 오늘부터 국회 의원실에 출근합니다.\n실제 상정된 법안들을 꼼꼼히 살피고,\n나라와 국민을 위한 최선의 표결을 내려보세요.',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 400.ms),
                                const SizedBox(height: 40),
  
                                // 주요 피처 카드 목록
                                _buildWebFeatureCard(
                                  emoji: '📋',
                                  title: 'AI 법안 요약 & 현장 생중계',
                                  description:
                                      '어려운 법안 조문을 쉽게 파악하고, 기대 효과와 현장의 우려 섞인 목소리를 직접 확인하세요.',
                                  delayMs: 450,
                                ),
                                const SizedBox(height: 16),
                                _buildWebFeatureCard(
                                  emoji: '🗳️',
                                  title: '나의 소중한 한 표',
                                  description:
                                      '찬성, 반대, 기권 등 나만의 올바른 소신을 투표로 표현하고 의정 기록에 남겨두세요.',
                                  delayMs: 600,
                                ),
                                const SizedBox(height: 16),
                                _buildWebFeatureCard(
                                  emoji: '🤝',
                                  title: '소울메이트 의원 매칭',
                                  description:
                                      '의정 활동 결과를 바탕으로 내 투표 성향을 분석해 나와 생각과 일치율이 가장 높은 국회의원을 찾아줍니다.',
                                  delayMs: 750,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 우측 스마트폰 디바이스 목업
                    Flexible(
                      flex: 4,
                      child: Center(
                        child: Container(
                          width: phoneWidth,
                          height: phoneHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: const Color(
                                  0xFF0F172A), // Sleek deep slate bezel
                              width: 12,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.03),
                                blurRadius: 60,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                // 내부의 자식 뷰들은 이 스마트폰 프레임 안으로 크기가 맞춰지도록
                                // MediaQuery 데이터를 새로 주입해 줍니다.
                                Positioned.fill(
                                  child: Builder(
                                    builder: (innerContext) {
                                      final originalData =
                                          MediaQuery.of(innerContext);
                                      final overriddenData =
                                          originalData.copyWith(
                                        size: Size(
                                            phoneWidth - 24, phoneHeight - 24),
                                        padding: originalData.padding.copyWith(
                                          top:
                                              36, // 아일랜드 노치를 피하기 위한 가상 세이프 에어리어 탑 패딩
                                          bottom: 12,
                                        ),
                                      );
                                      return MediaQuery(
                                        data: overriddenData,
                                        child: child,
                                      );
                                    },
                                  ),
                                ),

                                // 상단 다이나믹 아일랜드 / 스피커 홀 시뮬레이션
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 110,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1E293B),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFeatureCard({
    required String emoji,
    required String title,
    required String description,
    required int delayMs,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delayMs), duration: 400.ms)
        .slideX(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: delayMs),
            duration: 400.ms);
  }
}
