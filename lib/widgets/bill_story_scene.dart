import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/bill_model.dart';

/// 법안 내용을 한 장면씩 보여주는 캐릭터 중심 스토리 카드
class BillStoryScene extends StatelessWidget {
  final BillModel bill;
  final int step;

  const BillStoryScene({super.key, required this.bill, required this.step});

  @override
  Widget build(BuildContext context) {
    final scene = _sceneFor(bill, step);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${bill.categoryEmoji} ${bill.category}',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          bill.billName,
          style: AppTextStyles.headlineLarge.copyWith(height: 1.35),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scene.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scene.accentColor.withValues(alpha: 0.18),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _StoryStage(scene: scene),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.eyebrow,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: scene.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(scene.title, style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scene.accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            scene.character,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: scene.accentColor.withValues(alpha: 0.07),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  scene.speaker,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: scene.accentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scene.content,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryStage extends StatelessWidget {
  final _SceneData scene;

  const _StoryStage({required this.scene});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scene.surfaceColor,
                    scene.accentColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 22,
            child: Text(
              scene.environment,
              style: const TextStyle(fontSize: 54),
            ),
          ),
          Positioned(
            left: 24,
            top: 22,
            right: 92,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                scene.stageLine,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 42,
              color: scene.accentColor.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            left: 54,
            bottom: 24,
            child: _Character(emoji: scene.character, size: 72),
          ),
          Positioned(
            left: 150,
            bottom: 30,
            child: _Character(emoji: scene.companion, size: 58),
          ),
          Positioned(
            right: 46,
            bottom: 25,
            child: Text(scene.prop, style: const TextStyle(fontSize: 58)),
          ),
        ],
      ),
    );
  }
}

class _Character extends StatelessWidget {
  final String emoji;
  final double size;

  const _Character({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
    );
  }
}

_SceneData _sceneFor(BillModel bill, int step) {
  final summary = bill.summary;
  final cast = _castFor(bill.category, bill.billName);

  switch (step) {
    case 0:
      return _SceneData(
        eyebrow: '장면 1 · 법안이 나온 배경',
        title: '수석 보좌관의 현장 브리핑',
        speaker: '수석 보좌관',
        character: '👩‍💼',
        companion: cast.backgroundCharacter,
        prop: '📑',
        environment: '🏛️',
        stageLine: '"의원님, 먼저 이 문제가 왜 생겼는지 보시죠."',
        content: summary?.background ?? '법안의 배경 정보를 준비하고 있습니다.',
        accentColor: AppColors.secondary,
        surfaceColor: AppColors.secondarySurface,
      );
    case 1:
      return _SceneData(
        eyebrow: '장면 2 · 법안이 시행된 뒤',
        title: '시민의 생활에 생긴 좋은 변화',
        speaker: cast.positiveSpeaker,
        character: cast.positiveCharacter,
        companion: cast.positiveCompanion,
        prop: cast.positiveProp,
        environment: cast.positiveEnvironment,
        stageLine: '"정책 덕분에 일상이 이렇게 달라졌어요!"',
        content: summary?.pros ?? '기대 효과 정보를 준비하고 있습니다.',
        accentColor: AppColors.accent,
        surfaceColor: AppColors.accentSurface,
      );
    case 2:
      return _SceneData(
        eyebrow: '장면 3 · 다른 현장에서는',
        title: '시행 과정에서 생길 수 있는 부작용',
        speaker: cast.concernSpeaker,
        character: cast.concernCharacter,
        companion: cast.concernCompanion,
        prop: cast.concernProp,
        environment: cast.concernEnvironment,
        stageLine: '"좋은 취지지만, 이런 부담도 함께 생겼습니다."',
        content: summary?.cons ?? '우려 사항 정보를 준비하고 있습니다.',
        accentColor: AppColors.warning,
        surfaceColor: const Color(0xFFFFFBEB),
      );
    default:
      return const _SceneData(
        eyebrow: '최종 장면 · 의원님의 결정',
        title: '세 가지 장면을 모두 확인했습니다',
        speaker: '수석 보좌관',
        character: '👩‍💼',
        companion: '🙋',
        prop: '🗳️',
        environment: '🏛️',
        stageLine: '"이제 의원님의 판단을 기록하겠습니다."',
        content: '법안이 필요한 이유와 기대되는 변화, 시행 과정의 부작용을 함께 고려해 표결해주세요.',
        accentColor: AppColors.primary,
        surfaceColor: AppColors.primarySurface,
      );
  }
}

_SceneCast _castFor(String category, String billName) {
  if (billName.contains('반려동물')) {
    return const _SceneCast(
      backgroundCharacter: '🙋',
      positiveSpeaker: '반려동물 보호자',
      positiveCharacter: '🙋',
      positiveCompanion: '🐶',
      positiveProp: '🏡',
      positiveEnvironment: '🌳',
      concernSpeaker: '반려동물 업계 종사자',
      concernCharacter: '🧑‍⚕️',
      concernCompanion: '🐕',
      concernProp: '💸',
      concernEnvironment: '🏪',
    );
  }

  switch (category) {
    case '교육':
      return const _SceneCast(
        backgroundCharacter: '🧒',
        positiveSpeaker: '학생과 학부모',
        positiveCharacter: '🧒',
        positiveCompanion: '👩',
        positiveProp: '🍱',
        positiveEnvironment: '🏫',
        concernSpeaker: '학교 현장 담당자',
        concernCharacter: '🧑‍🏫',
        concernCompanion: '👨‍💼',
        concernProp: '💸',
        concernEnvironment: '🏫',
      );
    case '환경':
      return const _SceneCast(
        backgroundCharacter: '👧',
        positiveSpeaker: '아이를 키우는 시민',
        positiveCharacter: '👩',
        positiveCompanion: '👧',
        positiveProp: '🌳',
        positiveEnvironment: '🌤️',
        concernSpeaker: '제조업 현장 근로자',
        concernCharacter: '👨‍🏭',
        concernCompanion: '🧑‍🔧',
        concernProp: '📈',
        concernEnvironment: '🏭',
      );
    case '노동':
      return const _SceneCast(
        backgroundCharacter: '🛵',
        positiveSpeaker: '플랫폼 노동자',
        positiveCharacter: '👷',
        positiveCompanion: '🧑‍⚕️',
        positiveProp: '🦺',
        positiveEnvironment: '🏙️',
        concernSpeaker: '소규모 플랫폼 운영자',
        concernCharacter: '🧑‍💼',
        concernCompanion: '👨‍💻',
        concernProp: '💸',
        concernEnvironment: '🏢',
      );
    case '기술':
      return const _SceneCast(
        backgroundCharacter: '🧑‍💻',
        positiveSpeaker: 'AI 서비스를 쓰는 시민',
        positiveCharacter: '🧑‍💻',
        positiveCompanion: '👩‍💻',
        positiveProp: '🤖',
        positiveEnvironment: '🌐',
        concernSpeaker: '기술 스타트업 대표',
        concernCharacter: '👩‍💼',
        concernCompanion: '🧑‍💻',
        concernProp: '🔒',
        concernEnvironment: '🏢',
      );
    case '주거':
      return const _SceneCast(
        backgroundCharacter: '🧑',
        positiveSpeaker: '독립을 준비하는 청년',
        positiveCharacter: '🧑',
        positiveCompanion: '👩',
        positiveProp: '🔑',
        positiveEnvironment: '🏠',
        concernSpeaker: '공공임대 대기 시민',
        concernCharacter: '🧔',
        concernCompanion: '👩',
        concernProp: '💸',
        concernEnvironment: '🏢',
      );
    case '복지':
      return const _SceneCast(
        backgroundCharacter: '👵',
        positiveSpeaker: '이동이 편해진 어르신',
        positiveCharacter: '👵',
        positiveCompanion: '👴',
        positiveProp: '🚌',
        positiveEnvironment: '🚏',
        concernSpeaker: '대중교통 운영 담당자',
        concernCharacter: '🧑‍💼',
        concernCompanion: '🧑‍🔧',
        concernProp: '💸',
        concernEnvironment: '🚌',
      );
    default:
      return const _SceneCast(
        backgroundCharacter: '🙋',
        positiveSpeaker: '정책의 도움을 받은 시민',
        positiveCharacter: '🙋',
        positiveCompanion: '👨‍👩‍👧',
        positiveProp: '✨',
        positiveEnvironment: '🏙️',
        concernSpeaker: '부담이 늘어난 시민',
        concernCharacter: '🧑‍💼',
        concernCompanion: '🙍',
        concernProp: '💸',
        concernEnvironment: '🏢',
      );
  }
}

class _SceneData {
  final String eyebrow;
  final String title;
  final String speaker;
  final String character;
  final String companion;
  final String prop;
  final String environment;
  final String stageLine;
  final String content;
  final Color accentColor;
  final Color surfaceColor;

  const _SceneData({
    required this.eyebrow,
    required this.title,
    required this.speaker,
    required this.character,
    required this.companion,
    required this.prop,
    required this.environment,
    required this.stageLine,
    required this.content,
    required this.accentColor,
    required this.surfaceColor,
  });
}

class _SceneCast {
  final String backgroundCharacter;
  final String positiveSpeaker;
  final String positiveCharacter;
  final String positiveCompanion;
  final String positiveProp;
  final String positiveEnvironment;
  final String concernSpeaker;
  final String concernCharacter;
  final String concernCompanion;
  final String concernProp;
  final String concernEnvironment;

  const _SceneCast({
    required this.backgroundCharacter,
    required this.positiveSpeaker,
    required this.positiveCharacter,
    required this.positiveCompanion,
    required this.positiveProp,
    required this.positiveEnvironment,
    required this.concernSpeaker,
    required this.concernCharacter,
    required this.concernCompanion,
    required this.concernProp,
    required this.concernEnvironment,
  });
}
