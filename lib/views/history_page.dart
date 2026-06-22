import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/history_controller.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../app/constants/app_constants.dart';
import '../models/vote_model.dart';

/// 사용자의 누적 투표 기록(히스토리)을 조회하는 화면
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 이미 MainTabPage 바인딩에서 lazyPut 처리되어 있으므로 Get.find로 사용
    final controller = Get.find<HistoryController>();
    
    // 탭을 눌러 진입할 때마다 데이터를 갱신하도록 처리
    controller.loadHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          '의정 기록 보관소',
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final history = controller.historyList;

        if (history.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadHistory,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── 헤더 정보 요약 ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🗳️',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '누적 법안 심사 건수',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${history.length} 건 완료',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              ),

              // ── 활동 리스트 ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = history[index];
                      final dateStr =
                          '${item.answeredAt.year}.${item.answeredAt.month.toString().padLeft(2, '0')}.${item.answeredAt.day.toString().padLeft(2, '0')}';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                          boxShadow: AppConstants.cardShadow,
                          border: Border.all(
                            color: _getVoteColor(item.answer).withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                            onTap: () => _showHistoryDetail(context, item, dateStr),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  // 선택한 투표 인디케이터
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getVoteColor(item.answer)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.answer.label,
                                        style: TextStyle(
                                          color: _getVoteColor(item.answer),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 법안 제목 및 일자
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.billName,
                                          style: AppTextStyles.titleMedium.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          dateStr,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: index < 6 ? index * 80 : 0),
                            duration: 350.ms,
                          )
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            delay: Duration(milliseconds: index < 6 ? index * 80 : 0),
                            duration: 350.ms,
                          );
                    },
                    childCount: history.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 기록이 없을 때 보여주는 비어있는 화면
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🗳️',
                  style: TextStyle(fontSize: 54),
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              '아직 법안 심사 이력이 없습니다',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '의원실로 돌아가서 오늘의 법안들을 신중히 심사하고 첫 표결을 시작해보세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 투표 타입별 색상 설정
  Color _getVoteColor(VoteType type) {
    switch (type) {
      case VoteType.yes:
        return AppColors.voteYes;
      case VoteType.no:
        return AppColors.voteNo;
      case VoteType.abstain:
        return AppColors.textSecondary;
    }
  }

  /// 개별 기록 클릭 시 모달창 출력
  void _showHistoryDetail(BuildContext context, dynamic item, String dateStr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getVoteColor(item.answer).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.answer.label,
                style: TextStyle(
                  color: _getVoteColor(item.answer),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '심사 완료 보고서',
                style: AppTextStyles.headlineSmall,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Text(
              '법안명',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              item.billName,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '표결 일자',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              dateStr,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '확인',
                style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
