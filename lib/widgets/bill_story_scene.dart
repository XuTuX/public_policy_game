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
                        scene.usesAidePortrait
                            ? const _AidePortrait(size: 36)
                            : Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: scene.accentColor.withValues(
                                    alpha: 0.1,
                                  ),
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
                                _TypewriterText(
                                  text: scene.content,
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
                    if (scene.impact != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: scene.accentColor.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              step == 1
                                  ? Icons.trending_up_rounded
                                  : Icons.warning_amber_rounded,
                              size: 18,
                              color: scene.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                scene.impact!,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// 최종 표결 직전에는 큰 장면 대신 확인한 핵심 영향만 간결하게 보여준다.
class BillDecisionBrief extends StatelessWidget {
  final BillModel bill;

  const BillDecisionBrief({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final narrative = bill.narrative;

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
        Text(bill.billName, style: AppTextStyles.headlineLarge),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const _AidePortrait(size: 58),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '윤서 수석 보좌관',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '배경과 두 가지 현장을 모두 확인했습니다. 핵심만 다시 짚어드릴게요.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ImpactRow(
                icon: Icons.trending_up_rounded,
                label: '기대 효과',
                value: narrative?.positiveImpact ?? '정책의 기대 효과',
                color: AppColors.accent,
              ),
              const SizedBox(height: 10),
              _ImpactRow(
                icon: Icons.warning_amber_rounded,
                label: '주의할 점',
                value: narrative?.concernImpact ?? '시행 과정의 부담',
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ImpactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.titleMedium),
              ],
            ),
          ),
        ],
      ),
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
            child: scene.usesAidePortrait
                ? const _AidePortrait(size: 72)
                : _Character(emoji: scene.character, size: 72),
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

class _AidePortrait extends StatelessWidget {
  final double size;

  const _AidePortrait({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
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
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/characters/senior_aide.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.7),
      ),
    );
  }
}

class _TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final milliseconds = (text.length * 13).clamp(320, 950);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: milliseconds),
      curve: Curves.easeOut,
      builder: (context, length, child) {
        return Text(text.substring(0, length), style: style);
      },
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
  final narrative = bill.narrative;
  final cast = _castFor(bill.category, bill.billName);

  switch (step) {
    case 0:
      return _SceneData(
        eyebrow: '장면 1 · 법안이 나온 배경',
        title: '수석 보좌관의 현장 브리핑',
        speaker: '윤서 수석 보좌관',
        character: '👩‍💼',
        companion: cast.backgroundCharacter,
        prop: '📑',
        environment: '🏛️',
        stageLine: '"현장 자료를 정리해왔어요, 의원님."',
        content:
            narrative?.backgroundDialogue ??
            summary?.background ??
            '법안의 배경 정보를 준비하고 있습니다.',
        impact: null,
        usesAidePortrait: true,
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
        stageLine: '"정책이 시행된 뒤, 이런 변화가 생겼어요."',
        content:
            narrative?.positiveDialogue ??
            summary?.pros ??
            '기대 효과 정보를 준비하고 있습니다.',
        impact: narrative?.positiveImpact,
        usesAidePortrait: false,
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
        stageLine: '"좋은 취지지만, 다른 현장의 이야기도 들어주세요."',
        content:
            narrative?.concernDialogue ??
            summary?.cons ??
            '우려 사항 정보를 준비하고 있습니다.',
        impact: narrative?.concernImpact,
        usesAidePortrait: false,
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
        impact: null,
        usesAidePortrait: true,
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
  final String? impact;
  final bool usesAidePortrait;
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
    required this.impact,
    required this.usesAidePortrait,
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
