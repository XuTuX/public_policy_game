import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';
import '../models/bill_model.dart';
import '../models/vote_model.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../widgets/bill_story_scene.dart';
import '../widgets/loading_widget.dart';

/// 법안 미션 화면 — 6단계 스토리텔링 기반 UX
class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final PageController _pageController = PageController();
  final BillController _controller = Get.find<BillController>();

  @override
  void initState() {
    super.initState();
    // currentStep이 변경될 때 PageView를 동기화
    ever(_controller.currentStep, (step) {
      if (_pageController.hasClients && _pageController.page?.round() != step) {
        _pageController.animateToPage(
          step,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // 법안이 바뀔 때 (currentIndex 변경 시) currentStep이 0으로 초기화되는데, 이때 PageView도 0으로 바로 이동
    ever(_controller.currentIndex, (_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            '법안 ${_controller.progressText}',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const LoadingWidget(message: '법안 서류를 준비 중입니다...');
        }

        final bill = _controller.currentBill;
        if (bill == null) {
          return const Center(child: Text('법안이 없습니다'));
        }

        return Column(
          children: [
            // ── 진행 바 (심플) ──
            _SimpleProgressBar(controller: _controller),

            // ── 단계별 페이지 뷰 ──
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  _controller.setStep(index);
                },
                children: [
                  Step1IntroScene(bill: bill),
                  Step2BackgroundScene(bill: bill),
                  Step3ProsScene(bill: bill),
                  Step4ConsScene(bill: bill),
                  Step5SummaryScene(bill: bill, controller: _controller),
                ],
              ),
            ),

            // ── 하단 패널 ──
            _BottomPanel(controller: _controller, bill: bill),
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

/// 상단 심플 진행 바 (현재 단계 표시)
class _SimpleProgressBar extends StatelessWidget {
  final BillController controller;

  const _SimpleProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Obx(() {
        // 5단계(0~4) 중 현재 위치를 표시
        final stepProgress = (controller.currentStep.value + 1) / 5;
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: stepProgress,
            minHeight: 4,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      }),
    );
  }
}

/// 하단 컨트롤 패널 (1~4단계는 다음/이전 버튼, 5단계는 이전 버튼만)
class _BottomPanel extends StatelessWidget {
  final BillController controller;
  final BillModel bill;

  const _BottomPanel({required this.controller, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;

      // 5단계 (투표 화면)에서는 투표 직후 피드백이 있으면 하단 패널에 표시하고,
      // 평소에는 '이전' 버튼만 표시하거나 숨길 수 있습니다.
      // 여기서는 투표 피드백이 있을 때만 렌더링하고, 평소에는 패널 자체를 가볍게 유지합니다.
      final isAnimating = controller.isAnimating.value;
      final lastVote = controller.lastVoteType.value;

      if (step == 4) {
        if (isAnimating && lastVote != null) {
          return Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
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
            child: _VoteFeedback(voteType: lastVote, bill: bill),
          );
        }
        
        // 투표 대기 상태일 때는 '이전' 버튼만 간략하게 제공
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: AppColors.divider),
                  ),
                  child: const Text('이전 단계로'),
                ),
              ),
            ],
          ),
        );
      }

      // 1~4단계 (이전/다음 버튼)
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
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
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: controller.previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: AppColors.divider),
                      ),
                      child: const Text('이전'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: controller.nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('다음', style: AppTextStyles.buttonLarge),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}



/// 투표 직후 피드백 표시
class _VoteFeedback extends StatelessWidget {
  final VoteType voteType;
  final BillModel bill;

  const _VoteFeedback({required this.voteType, required this.bill});

  @override
  Widget build(BuildContext context) {
    final (icon, title, detail, color) = switch (voteType) {
      VoteType.yes => (
        Icons.check_circle_rounded,
        '찬성 의견을 기록했습니다',
        '기대 효과에 더 무게를 두었습니다.',
        AppColors.voteYes,
      ),
      VoteType.no => (
        Icons.cancel_rounded,
        '반대 의견을 기록했습니다',
        '부작용 우려에 더 무게를 두었습니다.',
        AppColors.voteNo,
      ),
      VoteType.abstain => (
        Icons.remove_circle_rounded,
        '기권 의견을 기록했습니다',
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
