import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/vote_model.dart';

/// 최종 표결용 카드 선택지
class NarrativeVoteButton extends StatelessWidget {
  final VoteType voteType;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isSelected;

  const NarrativeVoteButton({
    super.key,
    required this.voteType,
    required this.title,
    required this.description,
    required this.onPressed,
    this.enabled = true,
    this.isSelected = false,
  });

  Color get _color => switch (voteType) {
        VoteType.yes => AppColors.voteYes,
        VoteType.no => AppColors.voteNo,
        VoteType.abstain => AppColors.textSecondary,
      };

  Color get _surfaceColor => switch (voteType) {
        VoteType.yes => AppColors.voteYesBg,
        VoteType.no => AppColors.voteNoBg,
        VoteType.abstain => AppColors.surfaceVariant,
      };

  Widget _buildSymbol(BuildContext context) {
    const double size = 28;
    const double strokeWidth = 3.5;

    switch (voteType) {
      case VoteType.yes:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _color,
              width: strokeWidth,
            ),
          ),
        );
      case VoteType.abstain:
        return const SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.change_history_rounded,
            color: AppColors.textSecondary,
            size: size + 4,
          ),
        );
      case VoteType.no:
        return const SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.voteNo,
            size: size + 6,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? _color : AppColors.divider;
    final backgroundColor = isSelected
        ? _surfaceColor
        : enabled
            ? AppColors.surface
            : AppColors.surfaceVariant.withValues(alpha: 0.55);

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      label: '$title. $description',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor.withValues(alpha: enabled ? 1 : 0.45),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: enabled && !isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            splashColor: _color.withValues(alpha: 0.1),
            highlightColor: _color.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent : _surfaceColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: _buildSymbol(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: enabled
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

