import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';
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
                  child: BillStoryScene(bill: bill, step: step),
                ),
              ),
            ),
            _ActionPanel(controller: controller, step: step),
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
  final int step;

  const _ActionPanel({required this.controller, required this.step});

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
      child: AnimatedSwitcher(
        duration: AppConstants.animNormal,
        child: step < 3
            ? _NextSceneButton(
                key: ValueKey('next-$step'),
                step: step,
                onPressed: controller.nextScene,
              )
            : _VoteChoices(
                key: const ValueKey('vote-choices'),
                controller: controller,
              ),
      ),
    );
  }
}

class _NextSceneButton extends StatelessWidget {
  final int step;
  final VoidCallback onPressed;

  const _NextSceneButton({
    super.key,
    required this.step,
    required this.onPressed,
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
      ],
    );
  }
}

class _VoteChoices extends StatelessWidget {
  final BillController controller;

  const _VoteChoices({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAnimating = controller.isAnimating.value;
      final lastVote = controller.lastVoteType.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('👩‍💼', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '의원님, 최종 의견을 선택해주세요.',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NarrativeVoteButton(
            voteType: VoteType.yes,
            text: '기대 효과가 더 크다 (찬성)',
            enabled: !isAnimating,
            isSelected: isAnimating && lastVote == VoteType.yes,
            onPressed: () => controller.vote(VoteType.yes),
          ),
          NarrativeVoteButton(
            voteType: VoteType.abstain,
            text: '아직 판단하기 어렵다 (기권)',
            enabled: !isAnimating,
            isSelected: isAnimating && lastVote == VoteType.abstain,
            onPressed: () => controller.vote(VoteType.abstain),
          ),
          NarrativeVoteButton(
            voteType: VoteType.no,
            text: '부작용 우려가 더 크다 (반대)',
            enabled: !isAnimating,
            isSelected: isAnimating && lastVote == VoteType.no,
            onPressed: () => controller.vote(VoteType.no),
          ),
        ],
      );
    });
  }
}
