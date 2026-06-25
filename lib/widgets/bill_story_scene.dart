import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/bill_model.dart';
import '../models/argument_model.dart';

import '../widgets/narrative_vote_button.dart';
import '../models/vote_model.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';

// =========================================================================
// 1단계: 도입 소개 (Intro)
// =========================================================================
class Step1IntroScene extends StatelessWidget {
  final BillModel bill;

  const Step1IntroScene({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
          Text(
            _keepAll(bill.billName),
            style: AppTextStyles.headlineMedium.copyWith(
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 40),
          _AideChatBubble(
            text: '의원님, 이번 법안에 대해 순서대로 브리핑해 드리겠습니다.',
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2단계: 도입 배경 (Background) - 여러 개의 말풍선
// =========================================================================
class Step2BackgroundScene extends StatelessWidget {
  final BillModel bill;

  const Step2BackgroundScene({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final rawDialogues = bill.narrative?.backgroundDialoguesList ?? 
        ['배경 정보를 준비하지 못했습니다.'];

    final messages = <_ChatMessage>[];
    bool currentIsUser = false; // 기본은 보좌관(false) 시작

    for (final rawText in rawDialogues) {
      String text = rawText.trim();
      bool isUser = currentIsUser;

      final aideMatch = RegExp(r'^보좌관\s*:\s*').firstMatch(text);
      final userMatch = RegExp(r'^의원\s*:\s*').firstMatch(text);

      if (aideMatch != null) {
        isUser = false;
        text = text.substring(aideMatch.end).trim();
      } else if (userMatch != null) {
        isUser = true;
        text = text.substring(userMatch.end).trim();
      } else {
        // 접두사가 없는 경우 명확한 힌트 분석, 없으면 이전 화자 유지
        if (_isClearUserHeuristic(text)) {
          isUser = true;
        } else if (_isClearAideHeuristic(text)) {
          isUser = false;
        }
      }

      currentIsUser = isUser;
      messages.add(_ChatMessage(text: text, isUser: isUser));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: '도입 배경', step: 2),
          const SizedBox(height: 24),
          ...messages.asMap().entries.map((entry) {
            final idx = entry.key;
            final msg = entry.value;
            final isFirstFromSender = idx == 0 || messages[idx - 1].isUser != msg.isUser;
            return Padding(
              padding: EdgeInsets.only(bottom: isFirstFromSender ? 16 : 8),
              child: _DialogueChatBubble(
                text: msg.text,
                isUser: msg.isUser,
                showSenderInfo: isFirstFromSender,
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isClearUserHeuristic(String text) {
    final trimmed = text.trim();
    if (trimmed.contains('의원님')) return false;

    if (trimmed.startsWith('아,') ||
        trimmed.startsWith('그럼') ||
        trimmed.startsWith('이해했습니다') ||
        trimmed.startsWith('그렇군요') ||
        trimmed.startsWith('음,') ||
        trimmed.startsWith('오,')) {
      return true;
    }

    if (trimmed.endsWith('?') ||
        trimmed.contains('인가요') ||
        trimmed.contains('있었나요') ||
        trimmed.contains('하나요') ||
        trimmed.contains('되나요') ||
        trimmed.contains('알려주세요') ||
        trimmed.contains('있나요')) {
      return true;
    }

    return false;
  }

  bool _isClearAideHeuristic(String text) {
    final trimmed = text.trim();
    if (trimmed.contains('의원님')) return true;
    if (trimmed.contains('설명해') ||
        trimmed.contains('드립니다') ||
        trimmed.contains('보고') ||
        trimmed.contains('브리핑') ||
        trimmed.contains('지적이 있었습니다') ||
        trimmed.contains('우려가 있습니다') ||
        trimmed.contains('핵심입니다')) {
      return true;
    }
    return false;
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

/// 대화형 말풍선 (인덱스나 텍스트 내용에 따라 보좌관과 의원님을 구분하여 렌더링)
class _DialogueChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool showSenderInfo;

  const _DialogueChatBubble({
    required this.text,
    required this.isUser,
    required this.showSenderInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      // 의원님 (User) 말풍선 - 우측 정렬
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 52), // 보좌관 아바타 영역만큼 좌측 여백을 주어 너무 넓어지지 않게 함
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                      topRight: showSenderInfo ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    _keepAll(text),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // 보좌관 (Aide) 말풍선 - 좌측 정렬
      return _AideChatBubble(
        text: text,
        accentColor: AppColors.secondary,
        showSenderInfo: showSenderInfo,
      );
    }
  }
}

/// 한글 단어(어절) 단위 줄바꿈을 지원하여 글자가 잘리지 않도록 하는 헬퍼 함수
String _keepAll(String text) {
  return text.replaceAllMapped(RegExp(r'([^ \n])(?=[^ \n])'), (m) => '${m[1]}\u200D');
}


// =========================================================================
// 3단계: 찬성 의견 (Pros)
// =========================================================================
class Step3ProsScene extends StatelessWidget {
  final BillModel bill;

  const Step3ProsScene({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final pros = bill.summary?.prosList ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: '찬성 논리', step: 3, color: AppColors.accentDark),
          const SizedBox(height: 16),
          _AideChatBubble(
            text: '이 법안을 지지하는 사람들은 다음과 같이 이야기합니다.',
            accentColor: AppColors.accentDark,
          ),
          const SizedBox(height: 20),
          if (pros.isEmpty)
            const Text('찬성 논리가 등록되지 않았습니다.')
          else
            ...pros.map((arg) => _ArgumentCard(
                  argument: arg,
                  icon: Icons.thumb_up_alt_rounded,
                  color: AppColors.accentDark,
                )),
        ],
      ),
    );
  }
}

// =========================================================================
// 4단계: 반대 의견 (Cons)
// =========================================================================
class Step4ConsScene extends StatelessWidget {
  final BillModel bill;

  const Step4ConsScene({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final cons = bill.summary?.consList ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: '반대 및 우려사항', step: 4, color: AppColors.warning),
          const SizedBox(height: 16),
          _AideChatBubble(
            text: '반면, 이 법안에 우려를 표하는 사람들은 다음과 같은 부작용을 지적합니다.',
            accentColor: AppColors.warning,
          ),
          const SizedBox(height: 20),
          if (cons.isEmpty)
            const Text('우려 사항이 등록되지 않았습니다.')
          else
            ...cons.map((arg) => _ArgumentCard(
                  argument: arg,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                )),
        ],
      ),
    );
  }
}

// =========================================================================
// 5단계: 최종 정리 (Summary) 및 투표
// =========================================================================
class Step5SummaryScene extends StatelessWidget {
  final BillModel bill;
  final BillController controller;

  const Step5SummaryScene({super.key, required this.bill, required this.controller});

  @override
  Widget build(BuildContext context) {
    final posImpact = bill.narrative?.positiveImpact ?? '찬성 효과 요약이 없습니다.';
    final conImpact = bill.narrative?.concernImpact ?? '우려 사항 요약이 없습니다.';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: '보좌관 최종 정리', step: 5),
          const SizedBox(height: 24),
          _AideChatBubble(text: '의원님, 마지막으로 양측의 핵심 주장을 요약해 드립니다.'),
          const SizedBox(height: 24),
          _SummaryBox(
            title: '핵심 찬성 논리',
            description: posImpact,
            icon: Icons.thumb_up_alt_rounded,
            color: AppColors.accentDark,
          ),
          const SizedBox(height: 16),
          _SummaryBox(
            title: '핵심 반대 논리',
            description: conImpact,
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
          const SizedBox(height: 32),
          _AideChatBubble(text: '의원님은 어떻게 판단하시겠습니까?'),
          const SizedBox(height: 24),
          
          // 투표 버튼 영역
          Obx(() {
            final isAnimating = controller.isAnimating.value;
            // 투표 중이거나 투표를 마쳤으면 (isAnimating) 버튼을 비활성화하거나 숨길 수 있지만,
            // 하단 패널에 결과가 표시되므로 여기서는 버튼을 비활성화만 유지합니다.
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: NarrativeVoteButton(
                      voteType: VoteType.yes,
                      title: '찬성',
                      description: '기대 효과가\n더 크다',
                      enabled: !isAnimating,
                      isSelected: false,
                      onPressed: () => controller.vote(VoteType.yes),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NarrativeVoteButton(
                      voteType: VoteType.abstain,
                      title: '기권',
                      description: '더 깊은\n논의 필요',
                      enabled: !isAnimating,
                      isSelected: false,
                      onPressed: () => controller.vote(VoteType.abstain),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NarrativeVoteButton(
                      voteType: VoteType.no,
                      title: '반대',
                      description: '부작용 우려가\n더 크다',
                      enabled: !isAnimating,
                      isSelected: false,
                      onPressed: () => controller.vote(VoteType.no),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}



// =========================================================================
// 공통 컴포넌트
// =========================================================================

class _StepHeader extends StatelessWidget {
  final String title;
  final int step;
  final Color color;

  const _StepHeader({
    required this.title,
    required this.step,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'STEP $step',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(color: color),
        ),
      ],
    );
  }
}

/// 카카오톡/메신저 스타일의 보좌관 말풍선
class _AideChatBubble extends StatelessWidget {
  final String text;
  final Color accentColor;
  final bool showSenderInfo;

  const _AideChatBubble({
    required this.text,
    this.accentColor = AppColors.secondary,
    this.showSenderInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSenderInfo) ...[
          // 보좌관 아바타
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/characters/senior_aide.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.7),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text('👩‍💼', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else
          const SizedBox(width: 52), // 아바타 공간만큼 좌측 여백 유지

        // 이름 + 말풍선
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSenderInfo) ...[
                Text(
                  '수석 보좌관',
                  style: AppTextStyles.caption.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.only(
                    topRight: const Radius.circular(16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                    topLeft: showSenderInfo ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  _keepAll(text),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 찬성/반대 논리 항목을 표시하는 깔끔하고 직관적인 카드 컴포넌트
class _ArgumentCard extends StatelessWidget {
  final ArgumentModel argument;
  final IconData icon;
  final Color color;

  const _ArgumentCard({
    required this.argument,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // 좌측에 강조 라인을 줍니다
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: color,
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타이틀 영역
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _keepAll(argument.title),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 본문 설명
                Text(
                  _keepAll(argument.description),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                
                // 구체적 예시 영역
                if (argument.example.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _keepAll(argument.example),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
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
        ),
      ),
    );
  }
}

/// 5단계 요약 상자
class _SummaryBox extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _keepAll(title),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _keepAll(description),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
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
