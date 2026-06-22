import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bill_controller.dart';
import '../models/vote_model.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../widgets/progress_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/loading_widget.dart';

/// 법안 미션(표결) 화면
class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BillController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(context),
        ),
        title: Obx(() => Text(
              '법안 표결',
              style: AppTextStyles.headlineSmall,
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: '법안을 불러오고 있습니다...');
        }

        final bill = controller.currentBill;
        if (bill == null) {
          return const Center(child: Text('법안이 없습니다'));
        }

        return Column(
          children: [
            // ── 진행률 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Obx(() => ProgressHeader(
                    current: controller.currentIndex.value + 1,
                    total: controller.bills.length,
                    progress: controller.progress,
                  )),
            ),

            // ── 법안 내용 (스크롤) ──
            Expanded(
              child: Obx(() {
                final currentBill = controller.currentBill;
                if (currentBill == null) return const SizedBox.shrink();

                return AnimatedSwitcher(
                  duration: AppConstants.animNormal,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    key: ValueKey(currentBill.id),
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리 + 상태
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${currentBill.categoryEmoji} ${currentBill.category}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentBill.status,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 법안 제목
                        Text(
                          currentBill.billName,
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentBill.proposer,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 24),

                        // AI 요약 카드들
                        if (currentBill.summary != null) ...[
                          SummaryCard.background(
                              currentBill.summary!.background),
                          SummaryCard.pros(currentBill.summary!.pros),
                          SummaryCard.cons(currentBill.summary!.cons),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),

            // ── 투표 버튼 ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() {
                final isAnimating = controller.isAnimating.value;
                final lastVote = controller.lastVoteType.value;

                return Row(
                  children: [
                    // 찬성 버튼
                    Expanded(
                      child: _VoteActionButton(
                        voteType: VoteType.yes,
                        enabled: !isAnimating,
                        isSelected: isAnimating && lastVote == VoteType.yes,
                        onPressed: () => controller.vote(VoteType.yes),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 반대 버튼
                    Expanded(
                      child: _VoteActionButton(
                        voteType: VoteType.no,
                        enabled: !isAnimating,
                        isSelected: isAnimating && lastVote == VoteType.no,
                        onPressed: () => controller.vote(VoteType.no),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('표결 중단', style: AppTextStyles.headlineMedium),
        content: Text(
          '지금 나가면 진행 상황이 저장되지 않습니다.\n정말 나가시겠습니까?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: Text(
              '나가기',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 투표 액션 버튼 (애니메이션 포함)
class _VoteActionButton extends StatefulWidget {
  final VoteType voteType;
  final bool enabled;
  final bool isSelected;
  final VoidCallback onPressed;

  const _VoteActionButton({
    required this.voteType,
    required this.enabled,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<_VoteActionButton> createState() => _VoteActionButtonState();
}

class _VoteActionButtonState extends State<_VoteActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _VoteActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isYes => widget.voteType == VoteType.yes;
  Color get _color => _isYes ? AppColors.voteYes : AppColors.voteNo;
  Color get _bgColor => _isYes ? AppColors.voteYesBg : AppColors.voteNoBg;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.enabled) _controller.forward();
        },
        onTapUp: (_) {
          if (widget.enabled) {
            _controller.reverse();
            widget.onPressed();
          }
        },
        onTapCancel: () {
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 72,
          decoration: BoxDecoration(
            color: widget.isSelected ? _color : _bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _color.withValues(alpha: widget.enabled ? 0.4 : 0.15),
              width: 2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isYes ? '⭕' : '❌',
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 8),
                Text(
                  _isYes ? '찬성' : '반대',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: widget.isSelected ? Colors.white : _color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
