import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';
import '../models/bill_model.dart';
import '../models/vote_model.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../widgets/bill_story_scene.dart';
import '../widgets/loading_widget.dart';
import '../widgets/narrative_vote_button.dart';

/// 법안 미션 화면 — 채팅형 UI로 한 화면에 배경·장점·부작용을 보여주고 바로 표결
class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BillController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
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
        elevation: 0,
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
            // ── 진행 바 (심플) ──
            _SimpleProgressBar(controller: controller),

            // ── 대화형 콘텐츠 영역 ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: SingleChildScrollView(
                  key: ValueKey('${bill.id}-$step'),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: BillChatScene(bill: bill, step: step),
                ),
              ),
            ),

            // ── 하단 패널 ──
            step < 3 
                ? _NextScenePanel(controller: controller, step: step)
                : _VotePanel(controller: controller, bill: bill),
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

/// 상단 심플 진행 바
class _SimpleProgressBar extends StatelessWidget {
  final BillController controller;

  const _SimpleProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Obx(() {
        final progress = controller.progress;
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }),
    );
  }
}

/// 하단 표결 패널 — 바로 투표 가능
class _VotePanel extends StatelessWidget {
  final BillController controller;
  final BillModel bill;

  const _VotePanel({required this.controller, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(() {
        final isAnimating = controller.isAnimating.value;
        final lastVote = controller.lastVoteType.value;

        // 투표 후 피드백
        if (isAnimating && lastVote != null) {
          return _VoteFeedback(voteType: lastVote, bill: bill);
        }

        // 투표 선택지
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '이 법안에 대한 의원님의 판단은?',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
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
                      isSelected: false,
                      onPressed: () => controller.vote(VoteType.yes),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NarrativeVoteButton(
                      voteType: VoteType.abstain,
                      title: '기권',
                      description: '판단하기\n어렵다',
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
            ),
          ],
        );
      }),
    );
  }
}

/// 투표 직후 피드백 표시
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(color: color),
                ),
                const SizedBox(height: 3),
                Text(detail, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextScenePanel extends StatelessWidget {
  final BillController controller;
  final int step;

  const _NextScenePanel({required this.controller, required this.step});

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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(helper, style: AppTextStyles.caption),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: controller.nextScene,
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
                  onPressed: controller.previousScene,
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('이전 대화'),
                )
              else
                const SizedBox(width: 96),
              if (step < 2)
                TextButton(
                  onPressed: controller.skipToDecision,
                  child: const Text('핵심만 보고 표결'),
                )
              else
                const SizedBox(width: 96),
            ],
          ),
        ],
      ),
    );
  }
}
