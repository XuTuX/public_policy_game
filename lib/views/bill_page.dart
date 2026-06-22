import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';
import '../models/bill_model.dart';
import '../models/vote_model.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../widgets/bill_story_scene.dart';
import '../widgets/loading_widget.dart';
import '../widgets/narrative_vote_button.dart';

/// 법안 미션 화면 — 배경, 장점, 부작용을 순서대로 체험한 뒤 표결한다.
class BillPage extends StatelessWidget {
  const BillPage({super.key});

  static const _stepLabels = ['배경', '장점', '부작용', '결정'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BillController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(context),
        ),
        title: Obx(
          () => Text(
            '법안 ${controller.progressText}',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final enabled = controller.fastMode.value;
            return IconButton(
              tooltip: enabled ? '빠른 진행 끄기' : '빠른 진행 켜기',
              onPressed: controller.toggleFastMode,
              icon: Icon(
                Icons.speed_rounded,
                color: enabled ? AppColors.primary : AppColors.textTertiary,
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '법안 서류를 준비 중입니다...');
        }

        final bill = controller.currentBill;
        if (bill == null) {
          return const Center(child: Text('법안이 없습니다'));
        }

        final step = controller.sceneStep.value;

        return Column(
          children: [
            _SceneProgress(currentStep: step),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppConstants.animNormal,
                transitionBuilder: (child, animation) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey('${bill.id}-$step'),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: step == 3
                      ? BillDecisionBrief(bill: bill)
                      : BillStoryScene(bill: bill, step: step),
                ),
              ),
            ),
            _ActionPanel(controller: controller, bill: bill, step: step),
          ],
        );
      }),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('업무 중단', style: AppTextStyles.headlineMedium),
        content: Text(
          '지금 퇴근하시면 작성 중이던 서류가 저장되지 않습니다.\n정말 퇴근하시겠습니까?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 일하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: Text('퇴근하기', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SceneProgress extends StatelessWidget {
  final int currentStep;

  const _SceneProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: List.generate(BillPage._stepLabels.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final color = isCompleted || isCurrent
              ? AppColors.primary
              : AppColors.divider;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: AppConstants.animFast,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        BillPage._stepLabels[index],
                        style: AppTextStyles.caption.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textTertiary,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < BillPage._stepLabels.length - 1)
                  const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final BillController controller;
  final BillModel bill;
  final int step;

  const _ActionPanel({
    required this.controller,
    required this.bill,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, step == 3 ? 24 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: AppConstants.animNormal,
            child: step < 3
                ? _NextSceneButton(
                    key: ValueKey('next-$step'),
                    step: step,
                    onPressed: controller.nextScene,
                    onBack: controller.previousScene,
                    onSkip: controller.skipToDecision,
                  )
                : _VoteChoices(
                    key: const ValueKey('vote-choices'),
                    controller: controller,
                    bill: bill,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NextSceneButton extends StatelessWidget {
  final int step;
  final VoidCallback onPressed;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _NextSceneButton({
    super.key,
    required this.step,
    required this.onPressed,
    required this.onBack,
    required this.onSkip,
  });

  String get label {
    switch (step) {
      case 0:
        return '장점이 나타난 현장 보기';
      case 1:
        return '부작용이 생긴 현장도 보기';
      default:
        return '이제 표결하러 가기';
    }
  }

  String get helper {
    switch (step) {
      case 0:
        return '법안이 왜 필요한지 확인했습니다';
      case 1:
        return '기대되는 변화를 확인했습니다';
      default:
        return '우려되는 점까지 모두 확인했습니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('story_next_panel'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(helper, style: AppTextStyles.caption),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            key: const Key('story_next_button'),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.buttonLarge),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (step > 0)
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: const Text('이전 장면'),
              )
            else
              const SizedBox(width: 96),
            if (step < 2)
              TextButton(onPressed: onSkip, child: const Text('핵심만 보고 표결'))
            else
              const SizedBox(width: 96),
          ],
        ),
      ],
    );
  }
}

class _VoteChoices extends StatelessWidget {
  final BillController controller;
  final BillModel bill;

  const _VoteChoices({super.key, required this.controller, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAnimating = controller.isAnimating.value;
      final lastVote = controller.lastVoteType.value;

      if (isAnimating && lastVote != null) {
        return _VoteFeedback(voteType: lastVote, bill: bill);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _AideAvatar(size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '어떤 판단을 내리시겠어요?',
                      style: AppTextStyles.titleLarge,
                    ),
                    Text(
                      '가장 중요하게 본 기준을 선택해주세요.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: controller.previousScene,
                child: const Text('다시 보기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: NarrativeVoteButton(
                    voteType: VoteType.yes,
                    title: '찬성',
                    description: '기대 효과가\n더 크다',
                    enabled: !isAnimating,
                    isSelected: isAnimating && lastVote == VoteType.yes,
                    onPressed: () => controller.vote(VoteType.yes),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NarrativeVoteButton(
                    voteType: VoteType.abstain,
                    title: '기권',
                    description: '아직 판단하기\n어렵다',
                    enabled: !isAnimating,
                    isSelected: isAnimating && lastVote == VoteType.abstain,
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
                    isSelected: isAnimating && lastVote == VoteType.no,
                    onPressed: () => controller.vote(VoteType.no),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _AideAvatar extends StatelessWidget {
  final double size;

  const _AideAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySurface,
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

class _VoteFeedback extends StatelessWidget {
  final VoteType voteType;
  final BillModel bill;

  const _VoteFeedback({required this.voteType, required this.bill});

  @override
  Widget build(BuildContext context) {
    final narrative = bill.narrative;
    final (icon, title, detail, color) = switch (voteType) {
      VoteType.yes => (
        Icons.check_circle_rounded,
        '찬성 의견을 기록했습니다',
        narrative?.positiveImpact ?? '기대 효과에 더 무게를 두었습니다.',
        AppColors.voteYes,
      ),
      VoteType.no => (
        Icons.cancel_rounded,
        '반대 의견을 기록했습니다',
        narrative?.concernImpact ?? '부작용 우려에 더 무게를 두었습니다.',
        AppColors.voteNo,
      ),
      VoteType.abstain => (
        Icons.remove_circle_rounded,
        '추가 검토 의견을 기록했습니다',
        '기대 효과와 부작용을 더 살펴봐야 합니다.',
        AppColors.textSecondary,
      ),
    };

    return Container(
      key: const Key('vote_feedback'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(detail, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
