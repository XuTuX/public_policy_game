import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/bill_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// 법안 내용을 카카오톡/웹툰 스타일 대화형 UI로 한 화면에 보여주는 위젯
class BillChatScene extends StatelessWidget {
  final BillModel bill;
  final int step;

  const BillChatScene({super.key, required this.bill, required this.step});

  @override
  Widget build(BuildContext context) {
    final narrative = bill.narrative;
    final summary = bill.summary;
    final cast = _castFor(bill.category, bill.billName);

    final backgroundText = narrative?.backgroundDialogue ??
        summary?.background ??
        '법안의 배경 정보를 준비하고 있습니다.';
    final prosText =
        narrative?.positiveDialogue ?? summary?.pros ?? '기대 효과 정보를 준비하고 있습니다.';
    final consText =
        narrative?.concernDialogue ?? summary?.cons ?? '우려 사항 정보를 준비하고 있습니다.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 카테고리 칩 + 법안명 ──
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${bill.categoryEmoji} ${bill.category}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          bill.billName,
          style: AppTextStyles.headlineSmall.copyWith(
            height: 1.3,
            letterSpacing: -0.3,
          ),
        ),
        if (bill.voteDate != null || bill.dataAsOf != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (bill.voteDate != null)
                _SourceChip(
                  icon: Icons.how_to_vote_outlined,
                  label: '본회의 표결 ${_dateLabel(bill.voteDate!)}',
                ),
              _SourceChip(
                icon: Icons.auto_awesome_outlined,
                label: 'AI 요약',
              ),
              if (bill.officialSourceUrl.isNotEmpty)
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(bill.officialSourceUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('국회 공식 원문'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          Text(
            '※ AI 요약은 오류가 있을 수 있으므로 중요한 판단 전 공식 원문을 확인하세요.'
            '${bill.dataAsOf == null ? '' : '  데이터 기준 ${_dateTimeLabel(bill.dataAsOf!)}'}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // ── 대화 영역 ──
        // 1. 배경 설명 (항상 보임)
        _AnimatedBubble(
          show: step >= 0,
          child: _ChatBubble(
            avatar: '👩‍💼',
            name: '수석 보좌관',
            nameColor: AppColors.secondary,
            text: backgroundText,
            accentColor: AppColors.secondary,
            isAide: true,
          ),
        ),

        // 2. 장점 (step >= 1)
        _AnimatedBubble(
          show: step >= 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ChatBubble(
              avatar: cast.positiveCharacter,
              name: cast.positiveSpeaker,
              nameColor: AppColors.accent,
              text: prosText,
              accentColor: AppColors.accent,
              tag: '기대 효과',
              tagIcon: Icons.trending_up_rounded,
              tagText: narrative?.positiveImpact,
            ),
          ),
        ),

        // 3. 단점 (step >= 2)
        _AnimatedBubble(
          show: step >= 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ChatBubble(
              avatar: cast.concernCharacter,
              name: cast.concernSpeaker,
              nameColor: AppColors.warning,
              text: consText,
              accentColor: AppColors.warning,
              tag: '주의할 점',
              tagIcon: Icons.warning_amber_rounded,
              tagText: narrative?.concernImpact,
            ),
          ),
        ),

        // 4. 최종 요약 (step >= 3)
        _AnimatedBubble(
          show: step >= 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: BillDecisionBrief(bill: bill),
          ),
        ),
      ],
    );
  }

  static String _dateLabel(DateTime value) =>
      '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';

  static String _dateTimeLabel(DateTime value) =>
      '${_dateLabel(value.toLocal())} ${value.toLocal().hour.toString().padLeft(2, '0')}:${value.toLocal().minute.toString().padLeft(2, '0')}';
}

class _SourceChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SourceChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _AnimatedBubble extends StatelessWidget {
  final bool show;
  final Widget child;

  const _AnimatedBubble({required this.show, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: show ? 1.0 : 0.0,
        child: show ? child : const SizedBox.shrink(),
      ),
    );
  }
}

/// 카카오톡 스타일 대화 말풍선
class _ChatBubble extends StatelessWidget {
  final String avatar;
  final String name;
  final Color nameColor;
  final String text;
  final Color accentColor;
  final bool isAide;
  final String? tag;
  final IconData? tagIcon;
  final String? tagText;

  const _ChatBubble({
    required this.avatar,
    required this.name,
    required this.nameColor,
    required this.text,
    required this.accentColor,
    this.isAide = false,
    this.tag,
    this.tagIcon,
    this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아바타
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: isAide
              ? ClipOval(
                  child: Image.asset(
                    'assets/characters/senior_aide.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.7),
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                )
              : Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 18)),
                ),
        ),
        const SizedBox(width: 10),
        // 이름 + 말풍선
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.caption.copyWith(
                  color: nameColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                    topLeft: Radius.circular(3),
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 핵심 태그
                    if (tagText != null && tagText!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tagIcon != null)
                              Icon(tagIcon, size: 14, color: accentColor),
                            if (tagIcon != null) const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                tagText!,
                                style: AppTextStyles.caption.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

/// 최종 표결 직전 — 핵심 요약 (간결 버전)
class BillDecisionBrief extends StatelessWidget {
  final BillModel bill;

  const BillDecisionBrief({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final narrative = bill.narrative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 + 법안명
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${bill.categoryEmoji} ${bill.category}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          bill.billName,
          style: AppTextStyles.headlineSmall.copyWith(
            height: 1.3,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        // 수석 보좌관 요약
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/characters/senior_aide.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.7),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('👩‍💼', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '수석 보좌관',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                        topLeft: Radius.circular(3),
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '핵심만 다시 짚어드릴게요.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 기대 효과 / 주의할 점
        _CompactImpactRow(
          icon: Icons.trending_up_rounded,
          label: '기대 효과',
          value: narrative?.positiveImpact ?? '정책의 기대 효과',
          color: AppColors.accent,
        ),
        const SizedBox(height: 8),
        _CompactImpactRow(
          icon: Icons.warning_amber_rounded,
          label: '주의할 점',
          value: narrative?.concernImpact ?? '시행 과정의 부담',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _CompactImpactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompactImpactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────
// 캐릭터 캐스팅 (기존 유지)
// ───────────────────────────────────────────────

_SceneCast _castFor(String category, String billName) {
  if (billName.contains('반려동물')) {
    return const _SceneCast(
      positiveSpeaker: '반려동물 보호자',
      positiveCharacter: '🙋',
      concernSpeaker: '반려동물 업계 종사자',
      concernCharacter: '🧑‍⚕️',
    );
  }

  switch (category) {
    case '교육':
      return const _SceneCast(
        positiveSpeaker: '학생과 학부모',
        positiveCharacter: '🧒',
        concernSpeaker: '학교 현장 담당자',
        concernCharacter: '🧑‍🏫',
      );
    case '환경':
      return const _SceneCast(
        positiveSpeaker: '아이를 키우는 시민',
        positiveCharacter: '👩',
        concernSpeaker: '제조업 현장 근로자',
        concernCharacter: '👨‍🏭',
      );
    case '노동':
      return const _SceneCast(
        positiveSpeaker: '플랫폼 노동자',
        positiveCharacter: '👷',
        concernSpeaker: '소규모 플랫폼 운영자',
        concernCharacter: '🧑‍💼',
      );
    case '기술':
      return const _SceneCast(
        positiveSpeaker: 'AI 서비스를 쓰는 시민',
        positiveCharacter: '🧑‍💻',
        concernSpeaker: '기술 스타트업 대표',
        concernCharacter: '👩‍💼',
      );
    case '주거':
      return const _SceneCast(
        positiveSpeaker: '독립을 준비하는 청년',
        positiveCharacter: '🧑',
        concernSpeaker: '공공임대 대기 시민',
        concernCharacter: '🧔',
      );
    case '복지':
      return const _SceneCast(
        positiveSpeaker: '이동이 편해진 어르신',
        positiveCharacter: '👵',
        concernSpeaker: '대중교통 운영 담당자',
        concernCharacter: '🧑‍💼',
      );
    default:
      return const _SceneCast(
        positiveSpeaker: '정책의 도움을 받은 시민',
        positiveCharacter: '🙋',
        concernSpeaker: '부담이 늘어난 시민',
        concernCharacter: '🧑‍💼',
      );
  }
}

class _SceneCast {
  final String positiveSpeaker;
  final String positiveCharacter;
  final String concernSpeaker;
  final String concernCharacter;

  const _SceneCast({
    required this.positiveSpeaker,
    required this.positiveCharacter,
    required this.concernSpeaker,
    required this.concernCharacter,
  });
}
