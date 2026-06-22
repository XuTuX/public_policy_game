import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

/// 대화형 말풍선 (발의 배경 / 장점 / 문제점)
class SummaryCard extends StatelessWidget {
  final String speakerName;
  final String speakerEmoji;
  final String content;
  final Color bubbleColor;
  final Color textColor;

  const SummaryCard({
    super.key,
    required this.speakerName,
    required this.speakerEmoji,
    required this.content,
    required this.bubbleColor,
    required this.textColor,
  });

  /// 발의 배경 (보좌관)
  factory SummaryCard.background(String content) {
    return SummaryCard(
      speakerName: '수석 보좌관',
      speakerEmoji: '👩‍💼',
      content: '의원님, 이 법안의 발의 배경을 요약해 드립니다.\n\n$content',
      bubbleColor: AppColors.secondarySurface,
      textColor: AppColors.textPrimary,
    );
  }

  /// 장점 (찬성 측 시민/전문가)
  factory SummaryCard.pros(String content) {
    return SummaryCard(
      speakerName: '찬성하는 시민',
      speakerEmoji: '🙆‍♂️',
      content: '이 법안이 통과되면 이런 점이 정말 좋습니다!\n\n$content',
      bubbleColor: AppColors.accentSurface,
      textColor: AppColors.textPrimary,
    );
  }

  /// 문제점 (반대 측 시민/전문가)
  factory SummaryCard.cons(String content) {
    return SummaryCard(
      speakerName: '우려하는 시민',
      speakerEmoji: '🙅‍♀️',
      content: '하지만 이런 부작용이 생길 수 있어서 걱정됩니다.\n\n$content',
      bubbleColor: const Color(0xFFFFFBEB), // 연한 경고색
      textColor: AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 아바타
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                speakerEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 이름 + 말풍선
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    speakerName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(4), // 말풍선 꼬리 느낌
                    ),
                  ),
                  child: Text(
                    content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
